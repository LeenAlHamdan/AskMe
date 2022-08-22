import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:web_socket_channel/io.dart';

import 'error_dialog.dart';

class NewMessage extends StatefulWidget {
  final IOWebSocketChannel? channel;
  final int targetUserId;
  final StreamController streamController;
  final int consultancyId;

  const NewMessage(
    this.channel, {
    Key? key,
    required this.streamController,
    required this.targetUserId,
    required this.consultancyId,
  }) : super(key: key);

  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = TextEditingController();
  bool show = false;
  FocusNode focusNode = FocusNode();

  Widget emojiSelect() {
    var primaryColorDark = Theme.of(context).primaryColorDark;
    return Offstage(
      offstage: !show,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.3,
        child: EmojiPicker(
            config: Config(
                columns: 7,
                emojiSizeMax: 24 * (Platform.isIOS ? 1.30 : 1.0),
                verticalSpacing: 0,
                horizontalSpacing: 0,
                gridPadding: EdgeInsets.zero,
                initCategory: Category.RECENT,
                bgColor: const Color(0xFFF2F2F2),
                indicatorColor: primaryColorDark,
                iconColor: Colors.grey,
                iconColorSelected: primaryColorDark,
                progressIndicatorColor: primaryColorDark,
                backspaceColor: primaryColorDark,
                skinToneDialogBgColor: Colors.white,
                skinToneIndicatorColor: Colors.grey,
                enableSkinTones: true,
                showRecentsTab: true,
                recentsLimit: 28,
                replaceEmojiOnLimitExceed: false,
                noRecents: Text(
                  'no_recents'.tr,
                  style: const TextStyle(fontSize: 20, color: Colors.black26),
                  textAlign: TextAlign.center,
                ),
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: const CategoryIcons(),
                buttonMode: ButtonMode.MATERIAL),
            onEmojiSelected: (
              category,
              emoji,
            ) {
              if (mounted) {
                setState(() {
                  _controller.text = _controller.text + emoji.emoji;
                });
              }
            }),
      ),
    );
  }

  void _sendMessage() async {
    FocusScope.of(context).unfocus();
    if (mounted && show) {
      setState(() {
        show = !show;
      });
    }
    try {
      if (widget.channel == null) {
        throw const HttpException('error');
      }
      widget.channel!.sink.add(jsonEncode({
        "action": "message",
        "payload": {
          "targetUserId": widget.targetUserId,
          "content": _controller.text
        }
      }));
    } on HttpException catch (_) {
      showErrorDialog('error'.tr, context);
    } catch (error) {
      debugPrint(error.toString());
      showErrorDialog('error'.tr, context);
    }

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (show) {
          if (mounted) {
            setState(() {
              show = false;
            });
          }
        } else {
          Navigator.pop(context);
        }
        return Future.value(false);
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    onTap: () {
                      if (mounted) {
                        setState(() {
                          show = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: Icon(
                            show
                                ? Icons.keyboard
                                : Icons.emoji_emotions_outlined,
                          ),
                          onPressed: () {
                            if (!show) {
                              FocusScope.of(context).unfocus();
                              focusNode.unfocus();
                              focusNode.canRequestFocus = false;
                            }
                            if (mounted) {
                              setState(() {
                                show = !show;
                              });
                            }
                          },
                        ),
                        labelText: 'send_a_message'.tr),
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {
                          _controller.text;
                        });
                      }
                    },
                    onSubmitted: (value) =>
                        _controller.text.isEmpty ? null : _sendMessage,
                  ),
                ),
                IconButton(
                  color: Theme.of(context).primaryColor,
                  icon: const Icon(
                    Icons.send,
                  ),
                  onPressed: _controller.text.isEmpty ? null : _sendMessage,
                )
              ],
            ),
            show ? emojiSelect() : Container(),
          ],
        ),
      ),
    );
  }
}
