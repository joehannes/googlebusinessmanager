/// Builds a wa.me chat link from a phone number, or null when the number
/// has no usable digits. Accepts E.164 or loosely formatted input.
String? whatsappLinkFor(String? phoneNumber) {
  if (phoneNumber == null) return null;
  final digits = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.length < 6) return null;
  return 'https://wa.me/$digits';
}
