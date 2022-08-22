import 'package:ask_me/widgets/slider_item.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ItemsSliderWidget extends StatefulWidget {
  const ItemsSliderWidget({
    Key? key,
    required this.ads,
  }) : super(key: key);

  final List<Map<String, String>> ads;

  @override
  State<ItemsSliderWidget> createState() => _ItemsSliderWidgetState();
}

class _ItemsSliderWidgetState extends State<ItemsSliderWidget> {
  int _current1 = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CarouselSlider(
            options: CarouselOptions(
                autoPlay: true,
                viewportFraction: 1,
                height: 150,
                onPageChanged: (index, _) {
                  if (mounted) {
                    setState(() {
                      _current1 = index;
                    });
                  }
                }),
            items: widget.ads
                .map((item) => SliderItem(
                      item['image'] ?? '',
                      item['text'] ?? '',
                    ))
                .toList(),
          ),
          Positioned(
            bottom: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.ads.map((item) {
                int i = widget.ads.indexOf(item);
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current1 == i ? Colors.white : Colors.grey),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
