import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AnnouncementModel>> getAnnouncements() {
    return _firestore
        .collection('announcements')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => AnnouncementModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addAnnouncement(AnnouncementModel announcement) async {
    await _firestore.collection('announcements').add(announcement.toMap());
  }

  Future<void> deleteAnnouncement(String id) async {
    await _firestore.collection('announcements').doc(id).delete();
  }

  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    await _firestore.collection('announcements').doc(id).update(data);
  }
}