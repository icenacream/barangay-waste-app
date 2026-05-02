import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final String id;
  final String barangay;
  final String defaultTime;
  final List<String> collectionDays;

  SettingsModel({
    required this.id,
    required this.barangay,
    required this.defaultTime,
    required this.collectionDays,
  });

  factory SettingsModel.fromMap(String id, Map<String, dynamic> data) {
    final rawDays = List<String>.from(data['collectionDays'] ?? []);
    // Filter out any bad entries that contain commas
    final cleanDays = rawDays.where((d) => !d.contains(',')).toList();
    return SettingsModel(
      id: id,
      barangay: data['barangay'] ?? '',
      defaultTime: data['defaultTime'] ?? '7:00 AM',
      collectionDays: cleanDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barangay': barangay,
      'defaultTime': defaultTime,
      'collectionDays': collectionDays,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  bool isCollectionDay(DateTime date) {
    const dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = dayNames[date.weekday - 1];
    return collectionDays.contains(dayName);
  }
}

class ExceptionModel {
  final String id;
  final String barangay;
  final DateTime date;
  final String type;
  final String newTime;
  final String reason;
  final DateTime createdAt;

  ExceptionModel({
    required this.id,
    required this.barangay,
    required this.date,
    required this.type,
    required this.newTime,
    required this.reason,
    required this.createdAt,
  });

  factory ExceptionModel.fromMap(String id, Map<String, dynamic> data) {
    return ExceptionModel(
      id: id,
      barangay: data['barangay'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? 'none',
      newTime: data['newTime'] ?? '',
      reason: data['reason'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barangay': barangay,
      'date': Timestamp.fromDate(date),
      'type': type,
      'newTime': newTime,
      'reason': reason,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  bool get isCancelled => type == 'cancelled';
  bool get isRescheduled => type == 'rescheduled';
}
