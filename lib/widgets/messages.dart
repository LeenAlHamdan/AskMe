import 'dart:convert';

import 'package:ask_me/widgets/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/mesaage.dart';
import '../providers/consultancy_provider.dart';
import '../providers/user_provider.dart';
import 'error_dialog.dart';
import 'message_bubble.dart';

class Messages extends StatefulWidget {
  final Stream<dynamic> stream;
  final String? secondUserProfileImage;
  final String secondUserName;
  final int consultancyId;

  const Messages({
    Key? key,
    required this.stream,
    required this.secondUserName,
    required this.secondUserProfileImage,
    required this.consultancyId,
  }) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  var isInit = true;

  Future<List<Message>> getMessages(BuildContext context) async {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    final consultancyProv =
        Provider.of<ConsultancyProvider>(context, listen: false);
    try {
      if (widget.consultancyId != -1) {
        final result = await consultancyProv.fetchAndSetMessages(
            token, 0, widget.consultancyId,
            isRefresh: true);
        isInit = false;
        return result;
      }
      isInit = false;
    } catch (error) {
      debugPrint(error.toString());
      await showErrorDialog('error'.tr, context);
      Navigator.of(context).pop();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    return FutureBuilder(
      future: getMessages(context),
      builder: (ctx, futureSnapshot) {
        if (isInit &&
            futureSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return StreamBuilder(
            stream: widget.stream,
            initialData: futureSnapshot.data,
            builder: (ctx, chatSnapshot) {
              final initMessages = futureSnapshot.data as List<Message>;
              List<Message> messages = initMessages;
              if (chatSnapshot.hasData) {
                final chatDocs = chatSnapshot.data;

                if (chatDocs != null) {
                  if (chatDocs is String) {
                    Message loadedItem;

                    final data = json.decode(chatDocs);
                    final message = json.decode(data) as Map<String, dynamic>;
                    if (messages.firstWhereOrNull(
                            (element) => element.id == message['id']) ==
                        null) {
                      loadedItem = Message(
                        id: message['id'],
                        senderId: message['senderId'],
                        consultancyId: message['consultancyId'],
                        content: message['content'],
                        seenAt: message['seenAt'],
                        createdAt: DateTime.now().toIso8601String(),
                      );
                      messages.insert(0, loadedItem);
                    }
                  } else {
                    messages = chatDocs as List<Message>;
                  }
                }
              }

              return ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (ctx, index) {
                  String userName;
                  String? userImage;
                  bool isMe;
                  if (messages[index].senderId == userProv.currentUser.id) {
                    isMe = true;
                    userName = userProv.currentUser.fullName;
                    userImage = userProv.currentUser.profileImageUrl;
                  } else {
                    isMe = false;
                    userName = widget.secondUserName;
                    userImage = widget.secondUserProfileImage;
                  }
                  return MessageBubble(
                    message: messages[index].content,
                    userName: userName,
                    userImage: userImage,
                    isMe: isMe,
                    valueKey: ValueKey(index),
                    delevried: messages[index].seenAt != null,
                  );
                },
              );
            });
      },
    );
  }
}
