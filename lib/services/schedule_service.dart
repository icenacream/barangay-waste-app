import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<SettingsModel?> getSettings(String barangay) async {
    try {
      final query = await _firestore
          .collection('settings')
          .where('barangay', isEqualTo: barangay)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return null;
      return SettingsModel.fromMap(
        query.docs.first.id,
        query.docs.first.data(),
      );
    } catch (e) {
      return null;
    }
  }

  Stream<List<ExceptionModel>> getExceptions(String barangay) {
    return _firestore
        .collection('exceptions')
        .where('barangay', isEqualTo: barangay)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ExceptionModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<Map<String, dynamic>?> getNextCollection(String barangay) async {
    final settings = await getSettings(barangay);
    if (settings == null) return null;

    final exceptions = await _firestore
        .collection('exceptions')
        .where('barangay', isEqualTo: barangay)
        .where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
        )
        .get();

    final exceptionDates = <String, ExceptionModel>{};
    for (var doc in exceptions.docs) {
      final model = ExceptionModel.fromMap(doc.id, doc.data());
      final key = model.date.toIso8601String().substring(0, 10);
      exceptionDates[key] = model;
    }

    DateTime checkDate = DateTime.now();
    for (int i = 0; i <= 30; i++) {
      checkDate = DateTime.now().add(Duration(days: i));
      final dateKey = checkDate.toIso8601String().substring(0, 10);
      if (!settings.isCollectionDay(checkDate)) continue;
      final exception = exceptionDates[dateKey];
      if (exception != null && exception.isCancelled) continue;
      return {
        'date': checkDate,
        'time': exception != null && exception.isRescheduled
            ? exception.newTime
            : settings.defaultTime,
        'status': exception != null && exception.isRescheduled
            ? 'rescheduled'
            : 'scheduled',
        'barangay': barangay,
      };
    }
    return null;
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await _firestore
        .collection('settings')
        .doc(settings.id)
        .update(settings.toMap());
  }

  Future<void> addException(ExceptionModel exception) async {
    await _firestore.collection('exceptions').add(exception.toMap());
  }

  Future<void> deleteException(String exceptionId) async {
    await _firestore.collection('exceptions').doc(exceptionId).delete();
  }
}
