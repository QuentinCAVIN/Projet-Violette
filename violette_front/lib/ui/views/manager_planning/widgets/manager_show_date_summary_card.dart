import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:violette_front/models/show_date.dart';

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
    final dayStr = DateFormat('d', 'fr_FR').format(showDate.date);
    final monthStr = DateFormat('MMM', 'fr_FR').format(showDate.date);
    final timeStr = showDate.formattedMeetingTime.replaceFirst(':', 'h');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F7FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00C853),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF673AB7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    monthStr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    showDate.title,
                    style: const TextStyle(
                      color: Color(0xFF673AB7),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
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
