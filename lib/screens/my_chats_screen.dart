// ignore_for_file: use_rethrow_when_possible, invalid_use_of_protected_member

import 'dart:async';

import 'package:ask_me/models/consultancy.dart';
import 'package:ask_me/providers/consultancy_provider.dart';
import 'package:ask_me/screens/consultancy_screen.dart';
import 'package:ask_me/screens/profile_screen.dart';
import 'package:ask_me/widgets/app_drawer.dart';
import 'package:ask_me/widgets/circle_cached_image.dart';
import 'package:web_socket_channel/io.dart';

import '../models/http_exception.dart';
import '../providers/user_provider.dart';
import '../widgets/error_dialog.dart';
import '../widgets/load_more_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../widgets/loading_widget.dart';
import '../widgets/no_items_widget.dart';

class MyChatsScreen extends StatefulWidget {
  final IOWebSocketChannel? channel;
  final StreamController streamController;

  const MyChatsScreen(this.channel, this.streamController, {Key? key})
      : super(key: key);

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool _isLoading = false;

  bool loadMore = false;
  bool canLoad = true;

  int pageNum = 0;

  List<Consultancy> consultancies = [];

  late ScrollController _scrollController;

  bool hasError = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) async {
      try {
        if (mounted) {
          setState(() {
            _isLoading = true;
            canLoad = false;
          });
        }
        final userProv = Provider.of<UserProvider>(context, listen: false);
        final token = userProv.token;

        await Provider.of<ConsultancyProvider>(context, listen: false)
            .fetchAndSetConsultancy(token, 0, isRefresh: true);

        if (mounted) {
          setState(() {
            _isLoading = false;
            canLoad = true;
          });
        }
      } on HttpException catch (_) {
        canLoad = true;
        Future.delayed(Duration.zero)
            .then((_) => showErrorDialog('error'.tr, context));
      } catch (error) {
        canLoad = true;

        Future.delayed(Duration.zero)
            .then((_) => showErrorDialog('error'.tr, context));
      }
    });

    _scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );

    // Setup the listener.
    _scrollController.addListener(() {
      if (_scrollController.positions.first.atEdge) {
        if (_scrollController.positions.last.pixels ==
            _scrollController.positions.last.maxScrollExtent) {
          // You're at the bottom.
          if (hasError) return;

          if (canLoad) {
            if (mounted) {
              setState(() {
                loadMore = true;
              });
            }
            canLoad = false;
            getConsultancys();
          }
        } else {
          // You're at the top.

        }
      }
    });
  }

  Future<void> getConsultancys() async {
    final consultancyProvider =
        Provider.of<ConsultancyProvider>(context, listen: false);
    final userProv = Provider.of<UserProvider>(context, listen: false);

    if (consultancies.length == consultancyProvider.total) {
      canLoad = false;
      if (mounted) {
        setState(() {
          loadMore = false;
        });
      }
      return;
    }
    try {
      await consultancyProvider.fetchAndSetConsultancy(
        userProv.token,
        ++pageNum,
      );

      canLoad = true;
    } on HttpException catch (error) {
      pageNum--;
      canLoad = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMore = false;
        });
      }
      throw error;
    } catch (error) {
      pageNum--;
      canLoad = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMore = false;
        });
      }
      throw error;
    }
    if (mounted) {
      setState(() {
        loadMore = false;
      });
    }
  }

  Future<void> _refresh() async {
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final token = userProv.token;

      await Provider.of<ConsultancyProvider>(context, listen: false)
          .fetchAndSetConsultancy(
        token,
        0,
        isRefresh: true,
      );
      pageNum = 0;
    } on HttpException catch (_) {
      showErrorDialog('error'.tr, context);

      throw HttpException('error');
    } catch (error) {
      showErrorDialog('error'.tr, context);
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final consultanciesProvider = Provider.of<ConsultancyProvider>(context);

    consultancies = consultanciesProvider.consultancies;

    return Scaffold(
      key: scaffoldKey,
      primary: true,
      drawer: AppDrawer(widget.channel, widget.streamController),
      appBar: AppBar(
        elevation: 1,
        title: Image.asset(
          Get.locale == const Locale('ar')
              ? 'assets/images/logo_text_ar.png'
              : 'assets/images/logo_text_en.png',
          fit: BoxFit.contain,
          width: 120,
          height: AppBar().preferredSize.height,
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 32,
            )),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileScreen(widget.channel))),
              icon: const Icon(Icons.person)),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const LoadingWidget()
            : RefreshIndicator(
                onRefresh: () => _refresh(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: consultancies.isEmpty
                      ? const NoItemsWidget()
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                            minHeight: MediaQuery.of(context).size.height -
                                AppBar().preferredSize.height,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  consultancies.isEmpty
                                      ? const NoItemsWidget()
                                      : Container(),
                                  ...consultancies.map((consultancy) {
                                    final int userId;
                                    final String userName;
                                    final String userPhone;
                                    final String userEmail;
                                    final String? userProfileImageUrl;
                                    if (userProvider.userId ==
                                        consultancy.firstUserId) {
                                      userId = consultancy.secondUserId;
                                      userName = consultancy.secondUserName;
                                      userPhone = consultancy.secondUserPhone;
                                      userEmail = consultancy.secondUserEmail;
                                      userProfileImageUrl =
                                          consultancy.secondUserProfileImageUrl;
                                    } else {
                                      userId = consultancy.firstUserId;
                                      userName = consultancy.firstUserName;
                                      userPhone = consultancy.firstUserPhone;
                                      userEmail = consultancy.firstUserEmail;
                                      userProfileImageUrl =
                                          consultancy.firstUserProfileImageUrl;
                                    }
                                    return Card(
                                      margin: const EdgeInsets.all(6),
                                      child: ListTile(
                                        dense: true,
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      ConsultancyScreen(
                                                        widget.channel,
                                                        widget.streamController,
                                                        secondUserEmail:
                                                            userEmail,
                                                        secondUserPhone:
                                                            userPhone,
                                                        secondUserId: userId,
                                                        secondUserProfileImage:
                                                            userProfileImageUrl,
                                                        secondUserName:
                                                            userName,
                                                      )));
                                        },
                                        title: Text(userName),
                                        leading: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircleCachedImage(
                                                image: userProfileImageUrl,
                                                radius: 35),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  (loadMore)
                                      ? const LoadMoreWidget()
                                      : Container(),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
      ),
    );
  }
}
