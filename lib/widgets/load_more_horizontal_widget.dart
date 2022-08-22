import 'package:flutter/material.dart';

class LoadMoreHorizontalWidget extends StatelessWidget {
  const LoadMoreHorizontalWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).primaryColorDark,
          )),
    );
  }
}
