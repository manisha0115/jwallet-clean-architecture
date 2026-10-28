class Validators {
  Validators._();

  static String? required(String? value, {String label = 'This field'}) =>
      (value == null || value.trim().isEmpty) ? '$label is required' : null;

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter an amount';
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed <= 0) return 'Enter a valid amount greater than zero';
    return null;
  }

  static String? emailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email or mobile is required';
    return null;
  }
}
