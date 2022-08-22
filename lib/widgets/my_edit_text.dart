import 'package:flutter/material.dart';

class MyEditText extends StatelessWidget {
  const MyEditText({
    Key? key,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.onSubmitted,
    this.fontFamily,
    this.textFocusNode,
    this.textInputAction,
    this.textDirection,
    required this.textController,
    required this.title,
    this.keyboardType,
  }) : super(key: key);

  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final TextDirection? textDirection;
  final TextEditingController textController;
  final FocusNode? textFocusNode;
  final Function? onSubmitted;
  final String title;
  final String? fontFamily;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 8,
        left: 8,
        right: 8,
      ),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        style: TextStyle(
          fontSize: 14,
          fontFamily: fontFamily,
          color: Theme.of(context).primaryColorDark,
        ),
        cursorColor: Theme.of(context).primaryColor,
        decoration: InputDecoration(
            labelText: title,
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor)),
            labelStyle: TextStyle(
              color: Theme.of(context).primaryColor,
            )),
        enabled: enabled,
        textDirection: textDirection,
        focusNode: textFocusNode,
        controller: textController,
        obscureText: obscureText,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        onSubmitted:
            onSubmitted != null ? (value) => onSubmitted!(value) : (_) {},
        autofocus: autofocus,
      ),
    );
  }
}
