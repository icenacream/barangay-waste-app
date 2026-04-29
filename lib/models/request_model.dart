import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String residentId;
  final String residentName;
  final String barangay;
  final String type;
  final String message;
  final String status;
  final String adminReply;
  final DateTime createdAt;

  RequestModel({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.barangay,
    required this.type,
    required this.message,
    required this.status,
    required this.adminReply,
    required this.createdAt,
  });

  factory RequestModel.fromMap(String id, Map<String, dynamic> data) {
    return RequestModel(
      id: id,
      residentId: data['residentId'] ?? '',
      residentName: data['residentName'] ?? '',
      barangay: data['barangay'] ?? '',
      type: data['type'] ?? 'request',
      message: data['message'] ?? '',
      status: data['status'] ?? 'pending',
      adminReply: data['adminReply'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'residentId': residentId,
      'residentName': residentName,
      'barangay': barangay,
      'type': type,
      'message': message,
      'status': status,
      'adminReply': adminReply,
      'createdAt': FieldValue.serverTimestamp(),
      'repliedAt': null,
    };
  }
}