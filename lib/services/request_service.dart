import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/request_model.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<RequestModel>> getAllRequests() {
    return _firestore
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RequestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<RequestModel>> getRequestsByStatus(String status) {
    return _firestore
        .collection('requests')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RequestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<RequestModel>> getRequestsByResident(String residentId) {
    return _firestore
        .collection('requests')
        .where('residentId', isEqualTo: residentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RequestModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> submitRequest(RequestModel request) async {
    await _firestore.collection('requests').add(request.toMap());
  }

  Future<void> replyToRequest(String id, String reply) async {
    await _firestore.collection('requests').doc(id).update({
      'adminReply': reply,
      'status': 'replied',
      'repliedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRequest(String id) async {
    await _firestore.collection('requests').doc(id).delete();
  }
}
