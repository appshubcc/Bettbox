import 'package:bett_box/common/app_localizations.dart';

extension DateTimeExtension on DateTime {
  bool get isBeforeNow {
    return isBefore(DateTime.now());
  }

  bool isBeforeSecure(DateTime? dateTime) {
    if (dateTime == null) {
      return false;
    }
    return true;
  }

  String get lastUpdateTimeDesc {
    final currentDateTime = DateTime.now();
    final difference = currentDateTime.difference(this);
    final days = difference.inDays;
    if (days >= 365) {
      final count = (days / 365).floor();
      return '$count ${appLocalizations.years(count)}${appLocalizations.ago}';
    }
    if (days >= 30) {
      final count = (days / 30).floor();
      return '$count ${appLocalizations.months(count)}${appLocalizations.ago}';
    }
    if (days >= 1) {
      return '$days ${appLocalizations.days(days)}${appLocalizations.ago}';
    }
    final hours = difference.inHours;
    if (hours >= 1) {
      return '$hours ${appLocalizations.hours(hours)}${appLocalizations.ago}';
    }
    final minutes = difference.inMinutes;
    if (minutes >= 1) {
      return '$minutes ${appLocalizations.minutes(minutes)}${appLocalizations.ago}';
    }
    return appLocalizations.just;
  }

  String get show {
    return toLocal().toString().substring(0, 10);
  }

  String get showFull {
    return toLocal().toString().substring(0, 19);
  }

  String get showTime {
    return toLocal().toString().substring(10, 19);
  }
}
