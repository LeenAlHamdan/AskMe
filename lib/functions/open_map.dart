import 'package:maps_launcher/maps_launcher.dart';

Future<void> openMap(double latitude, double longitude) async {
  MapsLauncher.launchCoordinates(latitude, longitude);
}
