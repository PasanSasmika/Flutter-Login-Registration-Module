class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      mobile: json['mobile'] as String,
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String mobile;

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final letters = parts.length > 1
        ? parts.first[0] + parts.last[0]
        : parts.first[0];
    return letters.toUpperCase();
  }
}
