import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  throw UnimplementedError();
});

class BusinessRepository {
  late final AppDatabase database;

  Future<void> initialize() async {
    database = AppDatabase();
    await database.ensureSeeded();
  }

  Stream<List<BusinessProfile>> watchBusinesses() => database.watchBusinesses();
  Future<int> insertBusiness(BusinessProfileCompanion entry) => database.insertBusiness(entry);
  Future<List<StagingProductData>> fetchStagingProducts() => database.fetchStagingProducts();
}
