import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'circle_cached_image.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key? key,
    required this.message,
    required this.userName,
    required this.userImage,
    required this.isMe,
    required this.delevried,
    required ValueKey<int> valueKey,
  }) : super(key: key);

  final String message;
  final String userName;
  final String? userImage;
  final bool isMe;
  final bool delevried;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: Get.locale == const Locale('ar')
              ? isMe
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end
              : isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: Get.locale == const Locale('ar')
                  ? isMe
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end
                  : isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.grey[300]
                        : Theme.of(context).primaryColorDark,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: !isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(12),
                      bottomRight: isMe
                          ? const Radius.circular(0)
                          : const Radius.circular(12),
                    ),
                  ),
                  width: 140,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: Get.locale == const Locale('ar')
                        ? isMe
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end
                        : isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: <Widget>[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isMe
                                ? Colors.black
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Text(
                        message,
                        style: TextStyle(
                          color: isMe
                              ? Colors.black
                              : Theme.of(context).primaryColor,
                        ),
                        textAlign: isMe ? TextAlign.end : TextAlign.start,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            !isMe
                ? Container(padding: const EdgeInsets.only(bottom: 8.0))
                : Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 8.0, bottom: 8.0),
                    child: Icon(
                      delevried ? Icons.check_circle : Icons.radio_button_off,
                      size: 16,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  )
          ],
        ),
        Positioned(
          top: 0,
          left: isMe ? null : 130,
          right: isMe ? 130 : null,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            child: CircleCachedImage(
              image: userImage,
            ),
          ),
        ),
      ],
    );
  }
}
