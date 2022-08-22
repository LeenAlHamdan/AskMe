// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeySwitch extends StatefulWidget {
  final String onText;
  final String offText;
  final Function onChange;
  final bool initVal;

  MeySwitch({
    required this.onChange,
    required this.offText,
    required this.onText,
    this.initVal = false,
  });
  @override
  _MeySwitchState createState() => _MeySwitchState();
}

class _MeySwitchState extends State<MeySwitch>
    with SingleTickerProviderStateMixin {
  bool isChecked = false;
  final Duration _duration = const Duration(milliseconds: 370);
  late Animation<Alignment> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    isChecked = widget.initVal;

    _animationController =
        AnimationController(vsync: this, duration: _duration);

    _animation = AlignmentTween(
            begin:
                widget.initVal ? Alignment.centerRight : Alignment.centerLeft,
            end: widget.initVal ? Alignment.centerLeft : Alignment.centerRight)
        .animate(
      CurvedAnimation(
          parent: _animationController,
          curve: widget.initVal ? Curves.bounceIn : Curves.bounceOut,
          reverseCurve: widget.initVal ? Curves.bounceOut : Curves.bounceIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () async {
            if (mounted) {
              setState(() {
                if (_animationController.isCompleted) {
                  _animationController.reverse();
                } else {
                  _animationController.forward();
                }
                isChecked = !isChecked;
              });
            }
            await widget.onChange(isChecked);
          },
          child: Container(
            width: 60,
            height: 30,
            padding: Get.locale == const Locale('ar')
                ? null
                : const EdgeInsets.fromLTRB(0, 6, 0, 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(40),
              ),
              /* boxShadow: [
                BoxShadow(
                    color: isChecked ? Colors.green : Colors.red,
                    blurRadius: 12,
                    offset: Offset(0, 8))
              ], */
            ),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: _animation.value,
                  child: Container(
                    width: 25,
                    height: 25,
                    margin: EdgeInsets.only(
                      right: isChecked ? 2 : 0,
                      left: isChecked ? 0 : 2,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                ),
                Positioned(
                  left: isChecked ? 8 : null,
                  right: isChecked ? null : 8,
                  child: Text(
                    isChecked ? widget.onText : widget.offText,
                    style: TextStyle(color: Theme.of(context).backgroundColor),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
