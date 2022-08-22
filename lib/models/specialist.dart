class Specialist {
  int id;
  String name;
  final String phone;
  final String email;
  bool isOnline;
  String? profileImageUrl;
  double lat;
  double lng;
  String specializationNameAr;
  String specializationNameEn;
  String fieldNameAr;
  String fieldNameEn;

  double rating;
  double? distance;

  Specialist({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.profileImageUrl,
    required this.lat,
    required this.lng,
    required this.specializationNameAr,
    required this.specializationNameEn,
    required this.fieldNameAr,
    required this.fieldNameEn,
    required this.rating,
    required this.distance,
    required this.isOnline,
  });
}
