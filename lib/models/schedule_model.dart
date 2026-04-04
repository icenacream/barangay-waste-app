import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String barangay;
  final DateTime date;
  final String time;
  final String status;

  ScheduleModel({
    required this.id,
    required this.barangay,
    required this.date,
    required this.time,
    required this.status,
  });

  factory ScheduleModel.fromMap(String id, Map<String, dynamic> data) {
    return ScheduleModel(
      id: id,
      barangay: data['barangay'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      status: data['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barangay': barangay,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  
}