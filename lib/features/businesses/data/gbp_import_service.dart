import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_business_profile_manager/core/services/gbp_api_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';

class GbpImportResult {
  const GbpImportResult({required this.imported, required this.skipped});

  /// Locations turned into new local workspaces.
  final int imported;

  /// Locations that were already imported earlier (matched by GBP resource name).
  final int skipped;

  int get total => imported + skipped;
}

/// Pulls every business.google.com listing the signed-in Google user manages
/// and materializes each one as a local, already-linked workspace.
class GbpImportService {
  GbpImportService(this._gbp, this._repository);

  final GbpApiService _gbp;
  final BusinessRepository _repository;

  /// Runs the browser sign-in if needed, then imports all listings.
  Future<GbpImportResult> connectAndImport() async {
    if (!_gbp.isConnected) await _gbp.connect();
    return importAll();
  }

  Future<GbpImportResult> importAll() async {
    final accounts = await _gbp.listAccounts();
    if (accounts.isEmpty) {
      throw GbpException('No Business Profile accounts found for this Google user. '
          'Create your listing on business.google.com first.');
    }

    final existing = await _repository.getBusinesses();
    final known = existing.map((b) => b.gbpLocationName).whereType<String>().toSet();

    var imported = 0;
    var skipped = 0;
    for (final account in accounts) {
      for (final location in await _gbp.listLocations(account.name)) {
        if (known.contains(location.name)) {
          skipped++;
          continue;
        }
        await _repository.insertBusiness(BusinessProfilesCompanion.insert(
          name: location.title,
          category: Value(location.category ?? ''),
          address: Value(location.address ?? ''),
          latitude: Value(location.latitude),
          longitude: Value(location.longitude),
          phoneNumber: Value(location.phone),
          website: Value(location.website),
          gbpAccountName: Value(account.name),
          gbpLocationName: Value(location.name),
        ));
        known.add(location.name);
        imported++;
      }
    }
    return GbpImportResult(imported: imported, skipped: skipped);
  }
}

final gbpImportServiceProvider = Provider<GbpImportService>((ref) {
  return GbpImportService(
    ref.watch(gbpApiServiceProvider),
    ref.watch(businessRepositoryProvider),
  );
});
