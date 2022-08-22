import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyErrorWidget extends StatelessWidget {
  const MyErrorWidget({
    Key? key,
    required this.appBarHeight,
    required this.onPressed,
  }) : super(key: key);

  final double appBarHeight;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      //forza il Center ad avere l'altezza dello scaffold body
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - appBarHeight - 50,
      ),
      child: Center(
          child: Column(
        children: [
          Text(
            'check_connection'.tr,
            style: Theme.of(context).textTheme.headline6,
          ),
          IconButton(
              onPressed: () => onPressed(), icon: const Icon(Icons.refresh)),
        ],
      )),
    );
  }
}
