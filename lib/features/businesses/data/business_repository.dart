import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';

/// Overridden in main() with the initialized instance.
final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  throw UnimplementedError('businessRepositoryProvider must be overridden in main()');
});

/// All local persistence for businesses, staged catalog items and posts.
class BusinessRepository {
  BusinessRepository({AppDatabase? database}) : database = database ?? AppDatabase();

  final AppDatabase database;

  // ---- Businesses -------------------------------------------------------

  Stream<List<BusinessProfile>> watchBusinesses() =>
      (database.select(database.businessProfiles)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Stream<BusinessProfile?> watchBusiness(int id) =>
      (database.select(database.businessProfiles)..where((t) => t.id.equals(id)))
          .watchSingleOrNull();

  Future<BusinessProfile?> getBusiness(int id) =>
      (database.select(database.businessProfiles)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<List<BusinessProfile>> getBusinesses() =>
      database.select(database.businessProfiles).get();

  Future<int> insertBusiness(BusinessProfilesCompanion entry) =>
      database.into(database.businessProfiles).insert(entry);

  Future<void> updateBusiness(int id, BusinessProfilesCompanion entry) =>
      (database.update(database.businessProfiles)..where((t) => t.id.equals(id)))
          .write(entry);

  Future<void> deleteBusiness(int id) async {
    await (database.delete(database.stagingItems)..where((t) => t.businessId.equals(id))).go();
    await (database.delete(database.businessPosts)..where((t) => t.businessId.equals(id))).go();
    await (database.delete(database.businessProfiles)..where((t) => t.id.equals(id))).go();
  }

  // ---- Staging catalog ---------------------------------------------------

  Stream<List<StagingItem>> watchStagingItems(int businessId) =>
      (database.select(database.stagingItems)
            ..where((t) => t.businessId.equals(businessId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<StagingItem?> getStagingItem(int id) =>
      (database.select(database.stagingItems)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Distinct non-empty categories already used in this business's catalog —
  /// fed to the AI so it reuses them instead of inventing near-duplicates.
  Future<List<String>> stagingCategories(int businessId) async {
    final query = database.selectOnly(database.stagingItems, distinct: true)
      ..addColumns([database.stagingItems.category])
      ..where(database.stagingItems.businessId.equals(businessId) &
          database.stagingItems.category.isNotValue(''));
    final rows = await query.get();
    return rows
        .map((row) => row.read(database.stagingItems.category))
        .whereType<String>()
        .toList();
  }

  Future<int> insertStagingItem(StagingItemsCompanion entry) =>
      database.into(database.stagingItems).insert(entry);

  Future<void> insertStagingItems(List<StagingItemsCompanion> entries) =>
      database.batch((batch) => batch.insertAll(database.stagingItems, entries));

  Future<void> updateStagingItem(int id, StagingItemsCompanion entry) =>
      (database.update(database.stagingItems)..where((t) => t.id.equals(id))).write(entry);

  Future<void> deleteStagingItem(int id) =>
      (database.delete(database.stagingItems)..where((t) => t.id.equals(id))).go();

  /// Bulk-accept: marks every draft's price as user-verified.
  Future<void> verifyAllStagingPrices(int businessId) =>
      (database.update(database.stagingItems)
            ..where((t) => t.businessId.equals(businessId) & t.status.equals('draft')))
          .write(const StagingItemsCompanion(priceIsAiEstimate: Value(false)));

  // ---- Posts --------------------------------------------------------------

  Stream<List<BusinessPost>> watchPosts(int businessId) =>
      (database.select(database.businessPosts)
            ..where((t) => t.businessId.equals(businessId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<BusinessPost?> getPost(int id) =>
      (database.select(database.businessPosts)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertPost(BusinessPostsCompanion entry) =>
      database.into(database.businessPosts).insert(entry);

  Future<void> updatePost(int id, BusinessPostsCompanion entry) =>
      (database.update(database.businessPosts)..where((t) => t.id.equals(id))).write(entry);

  Future<void> deletePost(int id) =>
      (database.delete(database.businessPosts)..where((t) => t.id.equals(id))).go();
}
