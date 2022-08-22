import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showErrorDialog(String message, BuildContext context) async {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        'error_title'.tr,
        style: Theme.of(context).textTheme.headline6,
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(fontSize: 14),
      ),
      actions: [
        TextButton(
          child: Text('okay'.tr),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    ),
  );
}
