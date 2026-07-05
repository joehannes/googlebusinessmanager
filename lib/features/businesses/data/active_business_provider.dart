import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/core/services/key_store_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';

/// Currently selected workspace (business), persisted across restarts.
class ActiveBusinessNotifier extends Notifier<int?> {
  @override
  int? build() => ref.read(keyStoreProvider).activeBusinessId;

  void select(int? id) {
    state = id;
    ref.read(keyStoreProvider).setActiveBusinessId(id);
  }
}

final activeBusinessIdProvider =
    NotifierProvider<ActiveBusinessNotifier, int?>(ActiveBusinessNotifier.new);

final businessesProvider = StreamProvider<List<BusinessProfile>>((ref) {
  return ref.watch(businessRepositoryProvider).watchBusinesses();
});

/// The active business row, falling back to the first existing business
/// (and auto-selecting it) so features never dangle without a workspace.
final activeBusinessProvider = Provider<BusinessProfile?>((ref) {
  final businesses = ref.watch(businessesProvider).valueOrNull ?? const [];
  if (businesses.isEmpty) return null;
  final activeId = ref.watch(activeBusinessIdProvider);
  for (final business in businesses) {
    if (business.id == activeId) return business;
  }
  return businesses.first;
});
