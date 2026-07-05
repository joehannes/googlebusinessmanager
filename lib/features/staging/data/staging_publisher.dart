import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_business_profile_manager/core/services/gbp_api_service.dart';
import 'package:google_business_profile_manager/features/businesses/data/app_database.dart';
import 'package:google_business_profile_manager/features/businesses/data/business_repository.dart';

class PublishReport {
  const PublishReport({
    required this.published,
    required this.skippedUnverified,
    required this.failures,
    required this.photoWarnings,
  });

  final int published;
  final int skippedUnverified;
  final List<String> failures;
  final int photoWarnings;

  String get summary {
    final parts = <String>['$published published'];
    if (skippedUnverified > 0) parts.add('$skippedUnverified skipped (price not verified)');
    if (failures.isNotEmpty) parts.add('${failures.length} failed');
    if (photoWarnings > 0) parts.add('$photoWarnings photo uploads failed');
    return parts.join(' • ');
  }
}

/// Publishes staged catalog entries to the linked GBP location.
///
/// Google's public API surface has no product-catalog endpoint, so entries
/// are published as local posts (plus a gallery photo when one is staged) —
/// the closest real, TOS-compliant representation.
class StagingPublisher {
  StagingPublisher({required this.gbp, required this.repository});

  final GbpApiService gbp;
  final BusinessRepository repository;

  Future<PublishReport> publish({
    required BusinessProfile business,
    required List<StagingItem> items,
  }) async {
    final accountName = business.gbpAccountName;
    final locationName = business.gbpLocationName;
    if (accountName == null || locationName == null) {
      throw GbpException(
        'This business is not linked to a Google Business Profile location yet. '
        'Open the business detail and use "Connect & link location" first.',
      );
    }

    var published = 0;
    var skippedUnverified = 0;
    var photoWarnings = 0;
    final failures = <String>[];

    for (final item in items) {
      if (item.status == 'published') continue;
      if (item.priceIsAiEstimate && item.priceAmount.isNotEmpty) {
        // Guardrail: never publish an unverified AI price estimate.
        skippedUnverified++;
        continue;
      }
      final priceLine =
          item.priceAmount.isEmpty ? '' : '\n${item.priceAmount} ${item.currencyCode}';
      final summary = '${item.title}$priceLine\n\n${item.description}'.trim();
      try {
        await gbp.publishLocalPost(
          accountName: accountName,
          locationName: locationName,
          summary: summary,
          languageCode: item.language,
          ctaUrl: (item.landingUrl?.isNotEmpty ?? false) ? item.landingUrl : business.website,
        );
        if (item.imagePath != null) {
          try {
            await gbp.uploadPhoto(
              accountName: accountName,
              locationName: locationName,
              imagePath: item.imagePath!,
            );
          } on Exception {
            photoWarnings++;
          }
        }
        await repository.updateStagingItem(
          item.id,
          const StagingItemsCompanion(status: Value('published')),
        );
        published++;
      } on GbpException catch (error) {
        failures.add('${item.title}: ${error.message}');
      }
    }

    return PublishReport(
      published: published,
      skippedUnverified: skippedUnverified,
      failures: failures,
      photoWarnings: photoWarnings,
    );
  }
}

final stagingPublisherProvider = Provider<StagingPublisher>((ref) {
  return StagingPublisher(
    gbp: ref.watch(gbpApiServiceProvider),
    repository: ref.watch(businessRepositoryProvider),
  );
});
