// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:io';
import 'package:ask_me/widgets/show_information_dialog.dart';

import 'package:ask_me/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

import '../functions/launch_phone.dart';
import '../models/mesaage.dart';
import '../providers/consultancy_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/circle_cached_image.dart';
import '../widgets/error_dialog.dart';
import '../widgets/messages.dart';
import '../widgets/new_message.dart';

class ConsultancyScreen extends StatefulWidget {
  final int secondUserId;
  final String secondUserEmail;
  final String secondUserPhone;
  final String? secondUserProfileImage;
  final String secondUserName;

  final double? secondUserRating;
  final double? secondUserLat;
  final double? secondUserLng;
  final String? secondUserFieldNameAr;
  final String? secondUserFieldNameEn;
  final String? secondUserSpecializationNameAr;
  final String? secondUserSpecializationNameEn;

  final IOWebSocketChannel? channel;
  final StreamController streamController;
  const ConsultancyScreen(
    this.channel,
    this.streamController, {
    Key? key,
    required this.secondUserId,
    required this.secondUserName,
    required this.secondUserProfileImage,
    required this.secondUserEmail,
    required this.secondUserPhone,
    this.secondUserRating,
    this.secondUserLat,
    this.secondUserLng,
    this.secondUserFieldNameAr,
    this.secondUserFieldNameEn,
    this.secondUserSpecializationNameAr,
    this.secondUserSpecializationNameEn,
  }) : super(key: key);

  @override
  _ConsultancyScreenState createState() => _ConsultancyScreenState();
}

class _ConsultancyScreenState extends State<ConsultancyScreen> {
  List<Message> messages = [];
  int consultancyId = -1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((_) async {
      final token = Provider.of<UserProvider>(context, listen: false).token;
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      try {
        consultancyId =
            await Provider.of<ConsultancyProvider>(context, listen: false)
                .getConsultancyByUserId(token, widget.secondUserId);
      } on HttpException catch (_) {
        await showErrorDialog('error'.tr, context);
        Navigator.of(context).pop();
      } catch (error) {
        await showErrorDialog('error'.tr, context);
        Navigator.of(context).pop();
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          consultancyId;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //final userProv = Provider.of<UserProvider>(context);
    //socket.send('Hello World!');
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => showInformationDialog(
            context: context,
            userEmail: widget.secondUserEmail,
            userPhone: widget.secondUserPhone,
            userProfileImage: widget.secondUserProfileImage,
            userName: widget.secondUserName,
            userFieldNameAr: widget.secondUserFieldNameAr,
            userFieldNameEn: widget.secondUserFieldNameEn,
            userSpecializationNameAr: widget.secondUserSpecializationNameAr,
            userSpecializationNameEn: widget.secondUserSpecializationNameEn,
            userLat: widget.secondUserLat,
            userLng: widget.secondUserLng,
            userRating: widget.secondUserRating,
            userId: widget.secondUserId,
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CircleCachedImage(image: widget.secondUserProfileImage),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2.5,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    widget.secondUserName,
                  ),
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 32,
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
                onPressed: () {
                  launchPhoneURL(widget.secondUserPhone);
                },
                icon: const Icon(
                  Icons.call,
                  size: 32,
                )),
          ),
        ],
      ),
      drawer: AppDrawer(widget.channel, widget.streamController),
      body: _isLoading
          ? const LoadingWidget()
          : Column(
              children: [
                Expanded(
                  child: Messages(
                    stream: widget.streamController.stream,
                    secondUserName: widget.secondUserName,
                    secondUserProfileImage: widget.secondUserProfileImage,
                    consultancyId: consultancyId,
                  ),
                ),
                NewMessage(
                  widget.channel,
                  streamController: widget.streamController,
                  targetUserId: widget.secondUserId,
                  consultancyId: consultancyId,
                ),
              ],
            ),
    );
  }
}
