import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/error_dialog.dart';

Future<LatLng?> initLocationService(BuildContext context) async {
  final Location locationService = Location();
  LocationData? location;
  bool serviceEnabled;
  bool serviceRequestResult;
  bool _permission = false;
  LocationData? currentLocation;
  LatLng? currentLatLng;

  try {
    serviceEnabled = await locationService.serviceEnabled();

    if (serviceEnabled) {
      final permission = await locationService.requestPermission();
      _permission = permission == PermissionStatus.granted;

      if (_permission) {
        location = await locationService.getLocation();
        currentLocation = location;
      }
    } else {
      serviceRequestResult = await locationService.requestService();
      if (serviceRequestResult) {
        return await initLocationService(context);
      }
    }
    await locationService.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000,
    );
    if (currentLocation != null && currentLatLng == null) {
      currentLatLng =
          LatLng(currentLocation.latitude!, currentLocation.longitude!);
    }
    return currentLatLng;
  } on PlatformException catch (e) {
    debugPrint(e.toString());
    if (e.code == 'PERMISSION_DENIED') {
      // _serviceError = e.message;
      showErrorDialog('PERMISSION_DENIED'.tr, context)
          .then((value) => Navigator.of(context).pop());
    } else if (e.code == 'SERVICE_STATUS_ERROR') {
      //  _serviceError = e.message;
      showErrorDialog('SERVICE_STATUS_ERROR'.tr, context)
          .then((value) => Navigator.of(context).pop());
    } else {
      showErrorDialog('error'.tr, context)
          .then((value) => Navigator.of(context).pop());
    }
    location = null;
  }
  return null;
}
