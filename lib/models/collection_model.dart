import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionModel {
  final String id;
  final String barangay;
  final DateTime date;
  final String time;
  final String status; // 'scheduled' or 'completed'
  final String notes;
  final DateTime? completedAt;

  CollectionModel({
    required this.id,
    required this.barangay,
    required this.date,
    required this.time,
    required this.status,
    this.notes = '',
    this.completedAt,
  });

  factory CollectionModel.fromMap(String id, Map<String, dynamic> data) {
    return CollectionModel(
      id: id,
      barangay: data['barangay'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '7:00 AM',
      status: data['status'] ?? 'scheduled',
      notes: data['notes'] ?? '',
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barangay': barangay,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
      'notes': notes,
      'completedAt': null,
    };
  }

  bool get isCompleted => status == 'completed';
  bool get isScheduled => status == 'scheduled';
}
