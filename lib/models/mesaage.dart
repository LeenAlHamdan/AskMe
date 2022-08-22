class Message {
  final int id;
  final int senderId;
  final int consultancyId;
  String createdAt;
  String? seenAt;
  String content;

  Message({
    required this.id,
    required this.senderId,
    required this.consultancyId,
    required this.createdAt,
    required this.content,
    required this.seenAt,
  });
}

class MessageFullData {
  final int id;
  final int senderId;
  final int consultancyId;
  String createdAt;
  String name;
  String email;
  String phone;
  String? senderUserProfileImageUrl;
  String? seenAt;
  String content;

  MessageFullData({
    required this.id,
    required this.senderId,
    required this.consultancyId,
    required this.createdAt,
    required this.content,
    required this.seenAt,
    required this.name,
    required this.phone,
    required this.email,
    required this.senderUserProfileImageUrl,
  });
}
