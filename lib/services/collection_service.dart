import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/collection_model.dart';

class CollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CollectionModel>> getAllCollections() {
    return _firestore
        .collection('collections')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CollectionModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addCollection(CollectionModel collection) async {
    await _firestore.collection('collections').add(collection.toMap());
  }

  Future<void> updateCollection(String id, Map<String, dynamic> data) async {
    await _firestore.collection('collections').doc(id).update(data);
  }

  Future<void> markCompleted(String id) async {
    await _firestore.collection('collections').doc(id).update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteCollection(String id) async {
    await _firestore.collection('collections').doc(id).delete();
  }

  Stream<List<CollectionModel>> getCollectionsByStatus(String status) {
    return _firestore
        .collection('collections')
        .where('status', isEqualTo: status)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CollectionModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<Map<String, int>> getDashboardStats() async {
    final collections = await _firestore.collection('collections').get();
    final residents = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'resident')
        .get();
    final requests = await _firestore
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .get();
    final completed = collections.docs
        .where((d) => d.data()['status'] == 'completed')
        .length;

    return {
      'totalSchedules': collections.docs.length,
      'activeResidents': residents.docs.length,
      'pendingRequests': requests.docs.length,
      'completedCollections': completed,
    };
  }
}
