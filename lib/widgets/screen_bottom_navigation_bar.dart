import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScreenBottomNavigationBar extends StatelessWidget {
  const ScreenBottomNavigationBar({
    Key? key,
    required this.onTap,
    required this.text,
    required this.enabled,
  }) : super(key: key);
  final Function onTap;
  final String text;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: enabled ? () => onTap() : () {},
        child: Ink(
          padding: const EdgeInsets.all(8),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).backgroundColor,
              ),
            ),
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.all(8),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
      ),
    );
  }
}
