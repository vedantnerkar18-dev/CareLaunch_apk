import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/caregiver_profile.dart';
import '../models/child_profile.dart';
import '../models/screening_record.dart';

/// All Firestore reads and writes. Everything lives under the signed-in
/// caregiver:  users/{uid}/children/{childId}/screenings/{id}
class ProfileRepository {
  ProfileRepository(this._db, this._uid);
  final FirebaseFirestore _db;
  final String Function() _uid;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(_uid());
  CollectionReference<Map<String, dynamic>> get _children =>
      _userDoc.collection('children');

  static DateTime _time(Object? v) => v is Timestamp ? v.toDate() : DateTime.now();

  Future<void> saveCaregiver(CaregiverProfile p) => _userDoc.set({
        ...p.toMap(),
        'consentAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  /// The signed-in caregiver's profile, or null if it has not been saved.
  Stream<CaregiverProfile?> watchCaregiver() => _userDoc.snapshots().map(
        (s) => s.exists && s.data() != null
            ? CaregiverProfile.fromMap(s.data()!)
            : null,
      );

  Stream<List<ChildProfile>> watchChildren() =>
      _children.orderBy('createdAt').snapshots().map(
            (s) => [
              for (final d in s.docs) ChildProfile.fromMap(d.id, d.data()),
            ],
          );

  /// Returns the new child's id.
  Future<String> addChild(ChildProfile child) async {
    final ref = await _children.add({
      ...child.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Firestore does not delete sub-collections automatically, so the child's
  /// check-ins are removed together with the profile.
  Future<void> deleteChild(String childId) async {
    final ref = _children.doc(childId);
    final screenings = await ref.collection('screenings').get();
    final batch = _db.batch();
    for (final d in screenings.docs) {
      batch.delete(d.reference);
    }
    batch.delete(ref);
    await batch.commit();
  }

  Future<void> saveScreening(String childId, ScreeningRecord record) async {
    await _children.doc(childId).collection('screenings').add({
      ...record.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ScreeningRecord>> watchScreenings(String childId) => _children
      .doc(childId)
      .collection('screenings')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (s) => [
          for (final d in s.docs)
            ScreeningRecord.fromMap(d.id, _time(d.data()['createdAt']), d.data()),
        ],
      );
}

