enum Relationship {
  mother('Mother'),
  father('Father'),
  guardian('Legal guardian'),
  other('Other caregiver (authorised by the parent)');

  final String label;
  const Relationship(this.label);
}

/// The consent wording a caregiver agreed to. Change this value whenever the
/// wording changes, so every account records which version it accepted.
const String consentVersion = '2026-10-v1';

class CaregiverProfile {
  final String name;
  final Relationship relationship;
  final String email;
  final String? phone;

  const CaregiverProfile({
    required this.name,
    required this.relationship,
    required this.email,
    this.phone,
  });

  Map<String, dynamic> toMap() => {
        'name': name.trim(),
        'relationship': relationship.name,
        'email': email.trim(),
        'phone': (phone ?? '').trim().isEmpty ? null : phone!.trim(),
        'consentVersion': consentVersion,
      };

  factory CaregiverProfile.fromMap(Map<String, dynamic> m) => CaregiverProfile(
        name: (m['name'] as String?) ?? '',
        relationship:
            Relationship.values.asNameMap()[m['relationship']] ?? Relationship.other,
        email: (m['email'] as String?) ?? '',
        phone: m['phone'] as String?,
      );
}