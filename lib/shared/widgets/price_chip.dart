import 'package:flutter/material.dart';
import 'package:google_business_profile_manager/core/theme/app_theme.dart';

/// Price display that stays soft-amber with a warning tooltip while the
/// value is an unverified AI estimation, per the staging-engine spec.
class PriceChip extends StatelessWidget {
  const PriceChip({
    required this.amount,
    required this.currencyCode,
    required this.isAiEstimate,
    super.key,
  });

  final String amount;
  final String currencyCode;
  final bool isAiEstimate;

  @override
  Widget build(BuildContext context) {
    if (amount.isEmpty) {
      return Text('No price', style: Theme.of(context).textTheme.bodySmall);
    }
    final label = Text(
      '$amount $currencyCode',
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: isAiEstimate ? const Color(0xFF92400E) : null,
      ),
    );
    if (!isAiEstimate) return label;
    return Tooltip(
      message: 'AI Estimated Price — Please Verify.\nThis is a typical local market value, not your price.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: aiEstimateBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: aiEstimateColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFF92400E)),
            const SizedBox(width: 4),
            label,
          ],
        ),
      ),
    );
  }
}
