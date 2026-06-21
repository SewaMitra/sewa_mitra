import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ProviderCard extends StatelessWidget {
  final String name;
  final double rating;
  final int reviewCount;
  final double startingPrice;
  final String currency;
  final Widget avatar;
  final VoidCallback? onTap;

  const ProviderCard({
    super.key,
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.startingPrice,
    required this.currency,
    required this.avatar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 70,
                height: 70,
                child: avatar,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppTheme.starYellow, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$rating',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkText,
                        ),
                      ),
                      Text(
                        ' ($reviewCount)',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.greyText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Starts from $currency ${startingPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.lightOrange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.primaryOrange,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
