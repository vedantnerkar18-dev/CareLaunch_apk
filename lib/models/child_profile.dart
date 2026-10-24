/// One child. Only what the app needs: a first name or nickname, date of
/// birth (so the age band stays correct as the child grows), and two optional extras.
class ChildProfile {
  static const int minScreeningAge = 5;
  static const int maxScreeningAge = 14;

  final String id;
  final String name;
  final DateTime dob;
  final String? gender; // optional
  final String? language; // optional

  const ChildProfile({
    required this.id,
    required this.name,
    required this.dob,
    this.gender,
    this.language,
  });

  ChildProfile withId(String newId) => ChildProfile(
        id: newId,
        name: name.trim(),
        dob: dob,
        gender: gender,
        language: (language ?? '').trim().isEmpty ? null : language!.trim(),
      );

  int ageOn(DateTime today) {
    var age = today.year - dob.year;
    final hadBirthday = today.month > dob.month ||
        (today.month == dob.month && today.day >= dob.day);
    if (!hadBirthday) age--;
    return age;
  }

  /// The questions are written for ages 5 to 14.
  bool canScreenOn(DateTime today) {
    final age = ageOn(today);
    return age >= minScreeningAge && age <= maxScreeningAge;
  }

  /// The date is stored as text (2019-03-05) so time zones can never shift it.
  String get dobText =>
      '${dob.year.toString().padLeft(4, '0')}-'
      '${dob.month.toString().padLeft(2, '0')}-'
      '${dob.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'name': name.trim(),
        'dob': dobText,
        'gender': gender,
        'language': (language ?? '').trim().isEmpty ? null : language!.trim(),
      };

  factory ChildProfile.fromMap(String id, Map<String, dynamic> m) =>
      ChildProfile(
        id: id,
        name: (m['name'] as String?) ?? 'Child',
        dob: DateTime.parse(m['dob'] as String),
        gender: m['gender'] as String?,
        language: m['language'] as String?,
      );
}