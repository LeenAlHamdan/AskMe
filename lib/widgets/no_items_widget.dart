import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoItemsWidget extends StatelessWidget {
  const NoItemsWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height,
      ),
      child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            //forza il Center ad avere l'altezza dello scaffold body
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Center(
                child: Column(
              children: [
                Text(
                  'no_items_to_show'.tr,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            )),
          )),
    );
  }
}
