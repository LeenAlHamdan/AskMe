import 'dart:async';

import 'package:ask_me/providers/user_provider.dart';
import 'package:ask_me/screens/favorite_screen.dart';
import 'package:ask_me/screens/profile_screen.dart';
import 'package:ask_me/screens/questions_screen.dart';
import 'package:ask_me/screens/show_specializations_screen.dart';
import 'package:ask_me/screens/sign_in_screen.dart';
import 'package:ask_me/screens/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';

import '../screens/my_chats_screen.dart';
import '../screens/show_fields_screen.dart';
import '../screens/specialists_screen.dart';
import 'confirm_leave_dialog.dart';
import 'not_signed_dialog.dart';

class AppDrawer extends StatelessWidget {
  final IOWebSocketChannel? channel;
  final StreamController streamController;
  AppDrawer(this.channel, this.streamController, {Key? key}) : super(key: key);

  final fontName = Get.locale == const Locale('en') ? 'OpenSans' : 'DroidKufi';

  void signOutFunction(
    BuildContext context,
    //final FirebaseMessaging fcm,
  ) async {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    /* if (userProv.isAdmin()) {
    fcm.unsubscribeFromTopic('admin_topic'.tr);
  }
  fcm.unsubscribeFromTopic('${userProv.userId}-${Get.locale!.languageCode}');
 */
    userProv.signOut();
    if (channel != null) {
      channel!.sink.close();
    }
    Navigator.pop(context);

    Navigator.pop(context);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showLoadDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (cox) => AlertDialog(
              title: Text('loading'.tr),
              content: WillPopScope(
                onWillPop: () async => false,
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: Center(
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).primaryColor,
                        )),
                  ),
                ),
              ),
            ));
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return Container(
            color: Theme.of(context).backgroundColor,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              top: 15,
              left: Get.locale == const Locale('ar') ? 15 : 0,
              right: Get.locale == const Locale('ar') ? 15 : 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.of(context).pushNamed(
                      ShowFieldsScreen.routeName,
                    );
                  },
                  icon: SvgPicture.asset(
                    'assets/images/add_field.svg',
                    color: Theme.of(context).primaryColor,
                    width: 24,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'fields'.tr,
                        style: TextStyle(
                          fontFamily: fontName,
                          fontSize: 16,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ShowSpecializationsScreen(channel)));
                  },
                  icon: SvgPicture.asset(
                    'assets/images/add_specialization.svg',
                    color: Theme.of(context).primaryColor,
                    width: 24,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'specializations'.tr,
                        style: TextStyle(
                          fontFamily: fontName,
                          fontSize: 16,
                          color: Theme.of(context).primaryColorDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              width: double.infinity,
              height: 100,
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                Get.locale == const Locale('ar')
                    ? 'assets/images/logo_text_ar.png'
                    : 'assets/images/logo_text_en.png',
                fit: BoxFit.contain,
                width: 120,
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 10, left: 5),
                    child: Text('screens'.tr,
                        style: Theme.of(context).textTheme.bodyText1),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => QuestionsScreen(channel)));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 10, bottom: 10, right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).focusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'questoins'.tr,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              SpecialistsScreen(channel, streamController)));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 10, bottom: 10, right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).focusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'chat'.tr,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ProfileScreen(channel)));
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 10, bottom: 10, right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).focusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'my_profile'.tr,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: userProv.userIsSignd()
                        ? () {
                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => FavoriteScreen(channel)));
                          }
                        : () => notSignedDialog(context),
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 10, bottom: 10, right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).focusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'favorite'.tr,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: userProv.userIsSignd()
                    ? [
                        userProv.isAdmin()
                            ? GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _showBottomSheet(context);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      left: 10, bottom: 10, right: 10),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).focusColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  width: double.infinity,
                                  child: Text(
                                    'control'.tr,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                  ),
                                ),
                              )
                            : Container(),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) =>
                                    MyChatsScreen(channel, streamController)));
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 10, bottom: 10, right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).focusColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: double.infinity,
                            child: Text(
                              'my_consultancies'.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            confirmLeaveDialog(context, onLeave: () {
                              _showLoadDialog(context);
                              signOutFunction(
                                context,
                              );
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 10, bottom: 10, right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).focusColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: double.infinity,
                            child: Text(
                              'log_out'.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                  ),
                            ),
                          ),
                        )
                      ]
                    : [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).restorablePushNamed(
                                  SignInScreen.routeName,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                    left: 10, bottom: 10, right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).focusColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'sign_in'.tr,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.of(context).pushNamed(
                                  SignUpScreen.routeName,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                    left: 10, bottom: 10, right: 10),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).focusColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'sign_up'.tr,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
