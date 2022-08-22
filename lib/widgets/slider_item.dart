import 'package:flutter/material.dart';

class SliderItem extends StatefulWidget {
  final String image;
  final String text;

  const SliderItem(this.image, this.text, {Key? key}) : super(key: key);

  @override
  State<SliderItem> createState() => _SliderItemState();
}

class _SliderItemState extends State<SliderItem> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          widget.image,
          fit: BoxFit.fitWidth,
          height: 150,
          width: double.infinity,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Theme.of(context).backgroundColor,
                ),
          ),
        ),
      ],
    );
  }
}
