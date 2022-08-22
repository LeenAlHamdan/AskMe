class Answer {
  int id;
  String answer;
  String createdAt;
  int questionId;
  bool isSolution;
  bool isRated;
  String questionSubject;
  int userId;
  String userEmail;
  String userPhone;
  String userName;
  String? userProfileImageUrl;

  double rating;

  Answer({
    required this.id,
    required this.answer,
    required this.createdAt,
    required this.questionId,
    required this.isRated,
    required this.isSolution,
    required this.questionSubject,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.userProfileImageUrl,
    required this.rating,
  });
}
