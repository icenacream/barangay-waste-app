import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final String purok;
  final DateTime date;
  final String time;
  final String status;

  ScheduleModel({
    required this.id,
    required this.purok,
    required this.date,
    required this.time,
    required this.status,
  });

  factory ScheduleModel.fromMap(String id, Map<String, dynamic> data) {
    return ScheduleModel(
      id: id,
      purok: data['purok'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      status: data['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'purok': purok,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  
}