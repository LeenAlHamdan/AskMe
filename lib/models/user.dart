class User {
  final int id;
  final String phone;
  final String fullName;
  final String email;
  String password;
  int role;
  String? profileImageUrl;
  bool isSpecialist;

  User({
    required this.role,
    required this.email,
    required this.phone,
    required this.password,
    required this.id,
    required this.fullName,
    required this.profileImageUrl,
    required this.isSpecialist,
  });
}
