import 'package:url_launcher/url_launcher.dart';

void launchPhoneURL(String phoneNumber) async {
  String url = 'tel:' + phoneNumber;
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
