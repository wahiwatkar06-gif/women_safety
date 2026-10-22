class TrustedContact {
  String id;
  String name;
  String phone;
  String relationship;
  bool isAlertEnabled;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relationship = 'Family',
    this.isAlertEnabled = true,
  });

  bool isValidPhone() {
    final clean = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return clean.length >= 7 && RegExp(r'^\+?[0-9]+$').hasMatch(clean);
  }

  TrustedContact copyWith({
    String? id,
    String? name,
    String? phone,
    String? relationship,
    bool? isAlertEnabled,
  }) {
    return TrustedContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      isAlertEnabled: isAlertEnabled ?? this.isAlertEnabled,
    );
  }
}
