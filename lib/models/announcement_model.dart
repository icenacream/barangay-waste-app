import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String postedBy;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.postedBy,
    required this.createdAt,
  });

  factory AnnouncementModel.fromMap(String id, Map<String, dynamic> data) {
    return AnnouncementModel(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      postedBy: data['postedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'postedBy': postedBy,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}