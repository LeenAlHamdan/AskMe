import 'package:ask_me/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void notSignedDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (cox) {
        return AlertDialog(
          title: Text('you_are_not_signed'.tr),
          content: Text('sorry_you_are_not_signed'.tr),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(SignInScreen.routeName);
              },
              child: Ink(
                padding: const EdgeInsets.all(8),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Text(
                  'sign_in'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  border: Border.all(color: Theme.of(context).primaryColor),
                ),
                child: Text(
                  'continue_as_guest'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
            ),
          ],
        );
      });
}
