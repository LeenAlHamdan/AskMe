// ignore_for_file: use_rethrow_when_possible, unused_local_variable

import 'dart:io';

import 'package:ask_me/models/question.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:web_socket_channel/io.dart';
import '../providers/user_provider.dart';
import '../screens/favorite_screen.dart';
import '../screens/sign_in_screen.dart';
import '../screens/sign_up_screen.dart';
import '../screens/splash_screen.dart';
import '../widgets/confirm_leave_dialog.dart';
import '../widgets/error_dialog.dart';
import '../widgets/not_signed_dialog.dart';
import '../widgets/switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../widgets/load_more_horizontal_widget.dart';

class ProfileScreen extends StatefulWidget {
  final IOWebSocketChannel? channel;

  final bool? hasError;
  const ProfileScreen(this.channel, {Key? key, this.hasError})
      : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final List locale = [
    {'name': 'English', 'locale': const Locale('en')},
    {'name': 'عربي', 'locale': const Locale('ar')},
  ];

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  File _pickedImage = File('');
  var _isLoading = false;
  var _isLoadingPass = false;
  var picAreLoading = false;
  List<Question> fav = [];
  Widget? searchBox;
  var searchIcon = Icons.search;

  bool first = true;

  final _searchController = TextEditingController();

  final _lastPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newPasswordFocusNode = FocusNode();

  late final _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  );

  late Color pickerColor;

  late Color currentColor;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

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
    if (widget.channel != null) {
      widget.channel!.sink.close();
    }
    Navigator.pop(context);

    Navigator.pop(context);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showLoadDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (cox) => AlertDialog(
              backgroundColor: Theme.of(context).backgroundColor,
              scrollable: true,
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

  @override
  void didChangeDependencies() {
    if (first) {
      pickerColor = Theme.of(context).primaryColor;
      currentColor = Theme.of(context).primaryColor;
    }
    first = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _lastPasswordController.dispose();
    _newPasswordController.dispose();
    _controller.dispose();

    _newPasswordFocusNode.dispose();

    super.dispose();
  }

  _imgFromCamera() async {
    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (imageFile == null) {
      return;
    }
    if (mounted) {
      setState(() {
        _pickedImage = File(imageFile.path);
      });
    }
    changePic();
  }

  _imgFromGallery() async {
    final picker = ImagePicker();

    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (imageFile == null) {
      return;
    }

    if (mounted) {
      setState(() {
        _pickedImage = File(imageFile.path);
      });
    }
    changePic();
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: Text('gallery'.tr),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text('camera'.tr),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> changePic() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .updateProfileImage(_pickedImage);
    } on HttpException catch (_) {
      showErrorDialog('error'.tr, context);
    } catch (_) {
      showErrorDialog('error'.tr, context);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> updateLanguage(Locale locale) async {
    Get.back();
    Get.updateLocale(locale);
    await SharedPreferences.getInstance().then((value) {
      value.setString('Locale', locale.languageCode);
    });
  }

  Future<void> changePass() async {
    if (_lastPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      await showErrorDialog(errorMessage, context);
      changePaddwordDialog();

      return;
    }

    if (_newPasswordController.text.length < 8) {
      var errorMessage = 'WEAK_PASSWORD'.tr;
      showErrorDialog(errorMessage, context);
      changePaddwordDialog();

      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingPass = true;
      });
    }

    try {
      await Provider.of<UserProvider>(context, listen: false).changePassword(
          _lastPasswordController.text, _newPasswordController.text);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('pass_change'.tr),
          duration: const Duration(seconds: 2)));
    } on HttpException catch (error) {
      var errorMessage = 'authentication_failed'.tr;

      if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'INVALID_PASSWORD'.tr;
      }
      await showErrorDialog(errorMessage, context);
      changePaddwordDialog();
    } catch (_) {
      await showErrorDialog('error'.tr, context);
      changePaddwordDialog();
    }
    if (mounted) {
      setState(() {
        _isLoadingPass = false;
      });
    }
  }

  void changePaddwordDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (cox) {
          return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            scrollable: true,
            title: Text('change_password'.tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                    left: 8,
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textDirection: TextDirection.ltr,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                        labelText: 'last_password'.tr,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        )),
                    obscureText: true,
                    controller: _lastPasswordController,
                    onSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_newPasswordFocusNode),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                    left: 8,
                    right: 8,
                  ),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textDirection: TextDirection.ltr,
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                        labelText: 'new_password'.tr,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        )),
                    obscureText: true,
                    controller: _newPasswordController,
                    focusNode: _newPasswordFocusNode,
                    onSubmitted: (_) async {
                      Navigator.pop(context);

                      await changePass();
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  await changePass();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Text(
                    'save'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Text(
                    'cancel'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _refresh() async {
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);

      await userProv.fetchProfile();
    } on HttpException catch (_) {
      showErrorDialog('error'.tr, context);

      throw const HttpException('error');
    } catch (error) {
      showErrorDialog('error'.tr, context);
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final mobSize = MediaQuery.of(context).size;
    var appBar = AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(
          Icons.arrow_back_ios_outlined,
        ),
      ),
      elevation: 2,
      title: Image.asset(
        Get.locale == const Locale('ar')
            ? 'assets/images/logo_text_ar.png'
            : 'assets/images/logo_text_en.png',
        fit: BoxFit.contain,
        width: 120,
        height: AppBar().preferredSize.height,
      ),
      actions: [
        IconButton(
            onPressed: () => userProvider.userIsSignd()
                ? Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => FavoriteScreen(widget.channel)))
                : notSignedDialog(context),
            icon: const Icon(Icons.favorite)),
      ],
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
            (mobSize.height - AppBar().preferredSize.height - 24 - 12) * 0.06),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  border: Border(
                    top: BorderSide(
                        color: Theme.of(context).focusColor, width: 1.0),
                    bottom: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2.0),
                  )),
              child: Text(
                'personal'.tr,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headline4!
                    .copyWith(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
    return Scaffold(
      key: scaffoldKey,
      appBar: appBar,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refresh(),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: MediaQuery.of(context).size.height -
                    appBar.preferredSize.height,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.25),
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onLongPress: () => _showPicker(context),
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundColor: _isLoading ||
                                                userProvider.currentUser
                                                        .profileImageUrl !=
                                                    null
                                            ? null
                                            : Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                        child: _isLoading
                                            ? CircularProgressIndicator(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              )
                                            : userProvider.currentUser
                                                        .profileImageUrl ==
                                                    null
                                                ? SvgPicture.asset(
                                                    'assets/images/user_profile.svg',
                                                    color: Theme.of(context)
                                                        .backgroundColor,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: userProvider
                                                        .currentUser
                                                        .profileImageUrl!,
                                                    imageBuilder: (context,
                                                        imageProvider) {
                                                      return CircleAvatar(
                                                        radius: 50,
                                                        backgroundImage:
                                                            imageProvider,
                                                      );
                                                    },
                                                    placeholder: (context,
                                                            url) =>
                                                        const LoadMoreHorizontalWidget(),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: 150,
                                                    errorWidget: (context, url,
                                                            error) =>
                                                        const Icon(Icons.error),
                                                  ),
                                      ),
                                    ),
                                  ),
                                  userProvider.userIsSignd()
                                      ? Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: IconButton(
                                            onPressed: () =>
                                                _showPicker(context),
                                            icon: Icon(Icons.add_a_photo,
                                                size: 30,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, left: 8, right: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userProvider.userIsSignd()
                                          ? userProvider.currentUser.fullName
                                          : 'guest'.tr,
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        userProvider.userIsSignd()
                                            ? userProvider.isAdmin()
                                                ? 'admin'.tr
                                                : userProvider.isSpecialist()
                                                    ? 'specialist'.tr
                                                    : 'user'.tr
                                            : 'user'.tr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'language'.tr,
                          ),
                          trailing: MeySwitch(
                            onText: 'ع',
                            offText: 'E',
                            onChange: (val) async {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (cox) => const SplashScreen()));

                              final userProv = Provider.of<UserProvider>(
                                  context,
                                  listen: false);

                              /*  final prevLang = Get.locale!.languageCode;
                              final prevAdmin = 'admin_topic'.tr;
                              final prevAll = 'all_topic'.tr;

                                 FirebaseMessaging.instance
                                  .unsubscribeFromTopic(prevAll);

                              if (userProv.isAdmin()) {
                                FirebaseMessaging.instance
                                    .unsubscribeFromTopic(prevAdmin);
                              }
                              if (userProv.userIsSignd()) {
                                FirebaseMessaging.instance.unsubscribeFromTopic(
                                    '${userProv.userId}-$prevLang');
                              } */

                              if (val) {
                                await updateLanguage(locale[1]['locale']);
                              } else {
                                await updateLanguage(locale[0]['locale']);
                              }
/* 
                              FirebaseMessaging.instance
                                  .subscribeToTopic('all_topic'.tr);

                              if (userProv.isAdmin()) {
                                FirebaseMessaging.instance
                                    .subscribeToTopic('admin_topic'.tr);
                              }
                              if (userProv.userIsSignd()) {
                                FirebaseMessaging.instance.subscribeToTopic(
                                    '${userProv.userId}-${Get.locale!.languageCode}');
                              } */
                            },
                            initVal: Get.locale == locale[1]['locale'],
                          ),
                        ),
                        ItemWidget(
                            title: 'favorite'.tr,
                            onTap: () => userProvider.userIsSignd()
                                ? Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) =>
                                        FavoriteScreen(widget.channel)))
                                : notSignedDialog(context)),
                        ItemWidget(
                            title: 'change_password'.tr,
                            onTap: userProvider.userIsSignd()
                                ? changePaddwordDialog
                                : () => notSignedDialog(context)),
                        /*   ItemWidget(title: 'share_app'.tr, onTap: () {}),
                        ItemWidget(title: 'rate_app'.tr, onTap: () {}),
                        ItemWidget(title: 'customer_service'.tr, onTap: () {}),
                      */
                        /*            userProvider.isAdmin()
                            ? Column(
                                children: [
                                  const Divider(
                                    thickness: 2,
                                    height: 2,
                                  ),
                                  ItemWidget(
                                      title: 'specialists_list'.tr,
                                      onTap: () =>
                                          Navigator.of(context).pushNamed(
                                            MainScreen.routeName,
                                            arguments: {
                                              'pageIndex': 0,
                                              'designersList': true,
                                            },
                                          )),
                                  ItemWidget(
                                      title: 'users_list'.tr,
                                      onTap: () =>
                                          Navigator.of(context).pushNamed(
                                            MainScreen.routeName,
                                            arguments: {
                                              'pageIndex': 0,
                                              'usersList': true,
                                            },
                                          )),
                                ],
                              )
                            : Container(),
              */
                        userProvider.userIsSignd()
                            ? ItemWidget(
                                title: 'log_out'.tr,
                                onTap: () {
                                  confirmLeaveDialog(context, onLeave: () {
                                    _showLoadDialog();
                                    signOutFunction(
                                      context,
                                    );
                                  });
                                })
                            : Column(
                                children: [
                                  ItemWidget(
                                      title: 'sign_in'.tr,
                                      onTap: () =>
                                          Navigator.of(context).pushNamed(
                                            SignInScreen.routeName,
                                          )),
                                  ItemWidget(
                                      title: 'sign_up'.tr,
                                      onTap: () =>
                                          Navigator.of(context).pushNamed(
                                            SignUpScreen.routeName,
                                          )),
                                ],
                              ),
                      ],
                    ),
                  ),
                  _isLoadingPass
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  const ItemWidget({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
      ),
      onTap: () => onTap(),
    );
  }
}
