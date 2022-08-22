import '../models/http_exception.dart';
import '../providers/user_provider.dart';
import '../widgets/error_dialog.dart';
import '../widgets/load_more_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../widgets/my_edit_text.dart';

class RestPasswordScreen extends StatefulWidget {
  static const routeName = '/rest-password';

  const RestPasswordScreen({Key? key}) : super(key: key);

  @override
  _RestPasswordScreenState createState() => _RestPasswordScreenState();
}

class _RestPasswordScreenState extends State<RestPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _codeFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  bool _codeSended = false;
  String code = '';

  var _isLoading = false;

  Future<void> restPassword(BuildContext context) async {
    if (_emailController.text.isEmpty ||
        _codeController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    if (_passwordController.text.compareTo(_confirmPasswordController.text) !=
        0) {
      var errorMessage = 'not_matching_passwords'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }
    if (!_emailController.text.removeAllWhitespace.isEmail) {
      var errorMessage = 'INVALID_EMAIL'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    if (_passwordController.text.length < 8) {
      var errorMessage = 'WEAK_PASSWORD'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    final email = _emailController.text.removeAllWhitespace;
    final password = _passwordController.text;
    final code = _codeController.text;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .restPasswordWithCode(email, password, code);
      Navigator.of(context).pop();
    } on HttpException catch (error) {
      var errorMessage = 'authentication_failed'.tr;
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'EMAIL_NOT_FOUND'.tr;
      } else if (error.toString().contains('INVAILD_CODE')) {
        errorMessage = 'INVAILD_CODE'.tr;
      } else if (error.toString().contains('ERROR')) {
        errorMessage = 'error_message'.tr;
      }
      showErrorDialog(errorMessage, context);
    } catch (error) {
      var errorMessage = 'error_message'.tr;
      showErrorDialog(errorMessage, context);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> requestCode(BuildContext context) async {
    if (_emailController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    if (!_emailController.text.removeAllWhitespace.isEmail &&
        !_emailController.text.removeAllWhitespace.isPhoneNumber) {
      var errorMessage = 'INVALID_EMAIL_OR_NUMBER'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }
    final email = _emailController.text.removeAllWhitespace;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await Provider.of<UserProvider>(context, listen: false)
          .requestPasswordCode(email);
      if (mounted) {
        setState(() {
          _codeSended = true;
        });
      }
    } on HttpException catch (error) {
      var errorMessage = 'authentication_failed'.tr;
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'EMAIL_NOT_FOUND'.tr;
      } else if (error.toString().contains('ERROR')) {
        errorMessage = 'error_message'.tr;
      }
      showErrorDialog(errorMessage, context);
      if (mounted) {
        setState(() {
          _codeSended = false;
        });
      }
    } catch (error) {
      var errorMessage = 'error_message'.tr;
      showErrorDialog(errorMessage, context);
      if (mounted) {
        setState(() {
          _codeSended = false;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    _confirmPasswordController.dispose();

    _codeFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          height: deviceSize.height,
          width: deviceSize.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(
                    bottom: 8,
                    top: _codeSended ? 30 : 80,
                    right: 8,
                  ),
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 8, bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _codeSended
                              ? 'reset_password_title'.tr
                              : 'reset_password'.tr,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                      UnconstrainedBox(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 100,
                          fit: BoxFit.cover,
                          width: 100,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:
                      _codeSended ? codeSendedWidget() : codeNotSendedWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> codeSendedWidget() {
    return [
      MyEditText(
        title: 'email_or_phone'.tr,
        fontFamily: 'OpenSans',
        textDirection: TextDirection.ltr,
        enabled: !_isLoading,
        textController: _emailController,
        onSubmitted: (_) => FocusScope.of(context).requestFocus(_codeFocusNode),
      ),
      MyEditText(
          title: 'code'.tr,
          fontFamily: 'OpenSans',
          textDirection: TextDirection.ltr,
          enabled: !_isLoading,
          textController: _codeController,
          textFocusNode: _codeFocusNode,
          keyboardType: TextInputType.number,
          onSubmitted: (_) =>
              FocusScope.of(context).requestFocus(_passwordFocusNode)),
      MyEditText(
        title: 'new_password'.tr,
        fontFamily: 'OpenSans',
        textDirection: TextDirection.ltr,
        enabled: !_isLoading,
        obscureText: true,
        textFocusNode: _passwordFocusNode,
        textController: _passwordController,
        onSubmitted: (_) =>
            FocusScope.of(context).requestFocus(_confirmPasswordFocusNode),
      ),
      MyEditText(
        title: 'confirm_new_password'.tr,
        fontFamily: 'OpenSans',
        textDirection: TextDirection.ltr,
        enabled: !_isLoading,
        obscureText: true,
        textFocusNode: _confirmPasswordFocusNode,
        textController: _confirmPasswordController,
        onSubmitted: (_) => restPassword(context),
      ),
      if (_isLoading)
        const LoadMoreWidget()
      else
        Container(
          padding: const EdgeInsets.only(bottom: 8, top: 10),
          margin:
              const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 30),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'cancel'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    restPassword(context);
                  },
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Text(
                      'reset'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'no_code'.tr,
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              requestCode(context);
            },
            child: Text(
              'resend'.tr,
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> codeNotSendedWidget() {
    return [
      Padding(
        padding: EdgeInsets.only(
            bottom: 18,
            right: Get.locale == const Locale('ar') ? 24 : 0.0,
            left: Get.locale == const Locale('ar') ? 0 : 24.0),
        child: Text(
          'reset_password_subtitle'.tr,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headline1,
        ),
      ),
      MyEditText(
        title: 'email_or_phone'.tr,
        fontFamily: 'OpenSans',
        textDirection: TextDirection.ltr,
        enabled: !_isLoading,
        onSubmitted: (_) => requestCode(context),
        autofocus: true,
        textController: _emailController,
      ),
      if (_isLoading)
        const LoadMoreWidget()
      else
        Container(
          padding: const EdgeInsets.only(bottom: 8, top: 50),
          margin:
              const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 50),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Text(
                      'cancel'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    requestCode(context);
                  },
                  style: TextButton.styleFrom(padding: const EdgeInsets.all(0)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(5.0)),
                    ),
                    child: Text(
                      'send_code'.tr,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    ];
  }
}
