import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool?> confirmLeaveDialog(
  BuildContext context, {
  Function? onLeave,
}) async {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'confirm'.tr,
                style: TextStyle(
                  fontFamily: Get.locale == const Locale('en')
                      ? 'OpenSans'
                      : 'DroidKufi',
                  color: Theme.of(context).primaryColorDark,
                ),
              )),
          content: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'we_will_miss_you'.tr,
                style: TextStyle(
                  fontFamily: Get.locale == const Locale('en')
                      ? 'OpenSans'
                      : 'DroidKufi',
                ),
              )),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'stay'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Get.locale == const Locale('en')
                        ? 'OpenSans'
                        : 'DroidKufi',
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                if (onLeave != null) {
                  onLeave();
                }
              },
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'exit'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Get.locale == const Locale('en')
                        ? 'OpenSans'
                        : 'DroidKufi',
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ],
        );
      });
}
