class Consultancy {
  final int id;
  final int firstUserId;
  final int secondUserId;
  String createdAt;
  final String firstUserName;
  final String firstUserPhone;
  final String firstUserEmail;
  final String secondUserName;
  final String secondUserPhone;
  final String secondUserEmail;
  String? firstUserProfileImageUrl;
  String? secondUserProfileImageUrl;

  Consultancy({
    required this.id,
    required this.firstUserId,
    required this.secondUserId,
    required this.createdAt,
    required this.firstUserName,
    required this.firstUserEmail,
    required this.firstUserPhone,
    required this.secondUserName,
    required this.secondUserEmail,
    required this.secondUserPhone,
    required this.firstUserProfileImageUrl,
    required this.secondUserProfileImageUrl,
  });
}
