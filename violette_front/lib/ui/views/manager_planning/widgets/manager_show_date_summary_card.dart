import 'package:flutter/material.dart';
import 'package:violette_front/models/show_date.dart';
import 'package:violette_front/ui/common/app_theme.dart';
import 'package:violette_front/ui/widgets/common/date_badge.dart';

class ManagerShowDateSummaryCard extends StatelessWidget {
  final ShowDate showDate;
  final VoidCallback? onTap;

  const ManagerShowDateSummaryCard({
    super.key,
    required this.showDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = showDate.formattedMeetingTime.replaceFirst(':', 'h');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: VioletteTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            DateBadge(date: showDate.date),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showDate.title,
                    style: const TextStyle(
                      color: VioletteTheme.cardTitle,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: const TextStyle(
                      color: VioletteTheme.textOnCard,
                      fontSize: 14,
                    ),
                  ),
                  if (showDate.address.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      showDate.address,
                      style: const TextStyle(
                        color: VioletteTheme.textOnCard,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: showDate.status.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                showDate.status.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
