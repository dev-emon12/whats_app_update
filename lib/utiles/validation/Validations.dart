class MyValidator {
  /// Empty Text Validation
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  /// Phone Number Validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required.';
    }

    // Must be 11 digits in BD
    final phoneRegExp = RegExp(r'^\d{11}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format (11 digits required).';
    }

    return null;
  }

  // Normalize Phone
  static String normalizePhone(String input) {
    var s = input.trim();

    // remove spaces, dashes, brackets
    s = s.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // remove hidden iOS RTL/LTR characters
    s = s.replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E]'), '');

    // convert 00XXXXXXXX → +XXXXXXXX
    if (s.startsWith('00')) {
      s = '+${s.substring(2)}';
    }

    // allow only digits and +
    s = s.replaceAll(RegExp(r'[^0-9+]'), '');

    return s;
  }

  static bool isE164(String phone) {
    return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone);
  }
}
