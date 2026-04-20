import 'package:violette_front/models/enums/show_date_status.dart';
import 'package:violette_front/models/show_date.dart';

/// JSON REST `ShowDateDto` → [ShowDate].
class ShowDateMapper {
  ShowDateMapper._();

  static ShowDate fromJson(Map<String, dynamic> json) {
    final eventDate = _parseEventDate(json['eventDate']);
    final meetingTimeMinutes = _parseMeetingTimeToMinutes(json['meetingTime']);

    return ShowDate(
      id: _toId(json['id']),
      title: (json['displayTitle'] as String?)?.trim().isNotEmpty == true
          ? (json['displayTitle'] as String)
          : (json['cabaretShowTitle'] as String?) ?? '',
      date: eventDate,
      meetingTimeMinutes: meetingTimeMinutes,
      address: (json['location'] as String?) ?? '',
      totalRequiredArtists: _toInt(json['totalRequiredArtists']),
      description: json['showDetails'] as String?,
      status: fromApiStatus(json['status']),
      selectedCount: _toInt(json['selectedCount']),
      clientContactName: json['clientContactName'] as String?,
      clientContactPhone: json['clientContactPhone'] as String?,
    );
  }

  static ShowDateStatus fromApiStatus(dynamic rawStatus) {
    final normalized = (rawStatus ?? '').toString().trim().toUpperCase();
    switch (normalized) {
      case 'OPTION':
        return ShowDateStatus.option;
      case 'CONFIRMED':
        return ShowDateStatus.confirmed;
      case 'STAFFED':
        return ShowDateStatus.staffed;
      case 'CANCELLED':
        return ShowDateStatus.cancelled;
      case 'ARCHIVED':
        return ShowDateStatus.archived;
      case 'INQUIRY':
      default:
        return ShowDateStatus.inquiry;
    }
  }

  static String _toId(dynamic rawId) {
    if (rawId == null) return '';
    if (rawId is num) return rawId.toInt().toString();
    return rawId.toString();
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseEventDate(dynamic rawDate) {
    final raw = (rawDate ?? '').toString();
    if (raw.isEmpty) {
      return DateTime.now();
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return DateTime.now();
    }

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static int _parseMeetingTimeToMinutes(dynamic rawTime) {
    final raw = (rawTime ?? '').toString().trim();
    if (raw.isEmpty) return 0;

    final parts = raw.split(':');
    if (parts.length < 2) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }
}
