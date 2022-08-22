import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

void confirmDeleteDialog(BuildContext context, String title, Function onTap) {
  showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            scrollable: true,
            title: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'confirm_delete'.tr,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            content: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${'confirm_delete_subtitle'.tr} $title ${'question_mark'.tr}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            actions: [
              GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);

                    await onTap();
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'delete'.tr,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  )),
              GestureDetector(
                  onTap: () {
                    Navigator.of(ctx).pop();
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('cancel'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                        )),
                  )),
            ],
            actionsPadding: const EdgeInsets.all(8),
          ));
}
