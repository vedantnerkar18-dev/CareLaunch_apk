import 'package:flutter_test/flutter_test.dart';
import 'package:carelaunch/models/child_profile.dart';

void main() {
  test('withId keeps the details and tidies the text', () {
    final saved = ChildProfile(
      id: '',
      name: ' Aarav ',
      dob: DateTime(2018, 6, 5),
      gender: 'Boy',
      language: '  ',
    ).withId('abc123');

    expect(saved.id, 'abc123');
    expect(saved.name, 'Aarav');
    expect(saved.dob, DateTime(2018, 6, 5));
    expect(saved.gender, 'Boy');
    expect(saved.language, isNull);
  });
}