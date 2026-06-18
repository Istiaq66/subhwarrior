import '../constants/app_constants.dart';

/// Pure validation for user-supplied free text (IMPROVEMENT_PLAN D5).
/// Each method returns `null` when valid, or a human-readable error message.
class InputValidators {
  InputValidators._();

  /// Validates a username against length + charset rules. Trims first.
  static String? username(String value) {
    final v = value.trim();
    if (v.length < AppConstants.usernameMinLength) {
      return 'Name must be at least ${AppConstants.usernameMinLength} characters.';
    }
    if (v.length > AppConstants.usernameMaxLength) {
      return 'Name must be at most ${AppConstants.usernameMaxLength} characters.';
    }
    if (!AppConstants.usernamePattern.hasMatch(v)) {
      return 'Name can only contain letters, numbers, spaces and underscores.';
    }
    return null;
  }


  static String? email(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Email is required.';
    final pattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!pattern.hasMatch(v)) return 'Enter a valid email address.';
    return null;
  }
  
  static String? password(String value) {
    if (value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  static String? workDescription(String value) {
    if (value.trim().length > AppConstants.workDescriptionMaxLength) {
      return 'Description must be at most '
          '${AppConstants.workDescriptionMaxLength} characters.';
    }
    return null;
  }

  static String? reflection(String? value) {
    if (value == null) return null;
    if (value.trim().length > AppConstants.reflectionMaxLength) {
      return 'Reflection must be at most '
          '${AppConstants.reflectionMaxLength} characters.';
    }
    return null;
  }
}