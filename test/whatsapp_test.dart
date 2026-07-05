import 'package:flutter_test/flutter_test.dart';
import 'package:google_business_profile_manager/core/utils/whatsapp.dart';

void main() {
  group('whatsappLinkFor', () {
    test('builds wa.me link from E.164 number', () {
      expect(whatsappLinkFor('+1 809 555 0111'), 'https://wa.me/18095550111');
    });

    test('returns null for empty or too-short input', () {
      expect(whatsappLinkFor(null), isNull);
      expect(whatsappLinkFor(''), isNull);
      expect(whatsappLinkFor('123'), isNull);
    });
  });
}
