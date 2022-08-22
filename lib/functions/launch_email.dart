import 'package:url_launcher/url_launcher.dart';

void launchEmail(String email) async {
  final Uri params = Uri(
    scheme: 'mailto',
    path: email,
  );
  String url = params.toString();
  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
