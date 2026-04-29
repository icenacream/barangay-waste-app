import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<UserModel>> getAllResidents() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'resident')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => UserModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> updateUserStatus(String uid, String status) async {
    await _firestore.collection('users').doc(uid).update({'status': status});
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}
