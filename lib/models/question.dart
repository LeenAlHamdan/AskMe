class Question {
  int id;
  String userName;
  String? userProfileImageUrl;

  String fieldNameAr;
  String fieldNameEn;

  String subject;
  String question;
  String createdAt;

  Question({
    required this.id,
    required this.userName,
    required this.userProfileImageUrl,
    required this.subject,
    required this.question,
    required this.createdAt,
    required this.fieldNameAr,
    required this.fieldNameEn,
  });
}

class QuestionFullData {
  int id;
  int userId;
  String userName;
  String userPhone;
  String userEmail;
  String? userProfileImageUrl;
  bool isFavorite;

  int fieldId;
  String fieldNameAr;
  String fieldNameEn;

  String subject;
  String question;
  String createdAt;

  QuestionFullData({
    required this.id,
    required this.userName,
    required this.userProfileImageUrl,
    required this.subject,
    required this.question,
    required this.createdAt,
    required this.fieldId,
    required this.fieldNameAr,
    required this.fieldNameEn,
    required this.userId,
    required this.userPhone,
    required this.userEmail,
    this.isFavorite = false,
  });
}
