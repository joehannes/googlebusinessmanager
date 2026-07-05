import 'package:flutter_test/flutter_test.dart';
import 'package:google_business_profile_manager/core/services/ai_service.dart';

void main() {
  group('ListingDraft.fromJson', () {
    test('enforces Product Editor limits (name 58, description 1000)', () {
      final draft = ListingDraft.fromJson({
        'title': 'X' * 100,
        'description': 'D' * 1500,
        'category': 'Groceries',
        'kind': 'product',
        'priceAmount': '250',
        'currencyCode': 'dop',
        'language': 'ES',
        'landingUrl': 'https://en.wikipedia.org/wiki/Example',
      })!;
      expect(draft.title.length, lessThanOrEqualTo(ListingDraft.maxTitleLength));
      expect(draft.description.length, lessThanOrEqualTo(ListingDraft.maxDescriptionLength));
      expect(draft.currencyCode, 'DOP');
      expect(draft.language, 'es');
      expect(draft.landingUrl, 'https://en.wikipedia.org/wiki/Example');
    });

    test('drops non-http landing URLs and untitled entries', () {
      final draft = ListingDraft.fromJson({
        'title': 'Beach Cruise',
        'landingUrl': 'javascript:alert(1)',
      })!;
      expect(draft.landingUrl, isEmpty);
      expect(ListingDraft.fromJson({'description': 'no title'}), isNull);
    });
  });
}
