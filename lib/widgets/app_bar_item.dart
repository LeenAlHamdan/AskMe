import 'package:flutter/material.dart';

class AppBarItem extends StatelessWidget {
  const AppBarItem({
    Key? key,
    required this.title,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
  }) : super(key: key);

  final Function onTap;
  final String title;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: const EdgeInsets.all(6),
        height: 30,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Theme.of(context).primaryColor,
          ),
          color: backgroundColor,
        ),
      ),
    );
  }
}
