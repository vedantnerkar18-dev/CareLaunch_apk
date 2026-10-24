/// Form checks. Each returns an error message, or null when the value is fine.
class Validators {
  static String? name(String? v) {
    if ((v ?? '').trim().length < 2) return 'Enter a name (at least 2 letters)';
    return null;
  }

  static String? email(String? v) {
    final t = (v ?? '').trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? v) {
    if ((v ?? '').length < 8) return 'Use at least 8 characters';
    return null;
  }

  /// Optional. If filled in, it must be an Indian 10-digit mobile number.
  static String? phoneOptional(String? v) {
    final t = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (t.isEmpty) return null;
    final digits = t.startsWith('+91') ? t.substring(3) : t;
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(digits)) {
      return 'Enter a 10-digit mobile number';
    }
    return null;
  }
}