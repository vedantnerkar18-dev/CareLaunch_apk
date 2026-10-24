import 'package:flutter_test/flutter_test.dart';
import 'package:carelaunch/models/caregiver_profile.dart';

void main() {
  test('a caregiver profile survives a save and load', () {
    final saved = const CaregiverProfile(
      name: ' Meera ',
      relationship: Relationship.mother,
      email: 'meera@example.com',
      phone: '9876543210',
    ).toMap();
    final back = CaregiverProfile.fromMap(saved);
    expect(back.name, 'Meera');
    expect(back.relationship, Relationship.mother);
    expect(back.email, 'meera@example.com');
    expect(back.phone, '9876543210');
  });

  test('missing or unknown values do not crash loading', () {
    final back = CaregiverProfile.fromMap({'relationship': 'somethingNew'});
    expect(back.name, '');
    expect(back.relationship, Relationship.other);
    expect(back.phone, isNull);
  });
}