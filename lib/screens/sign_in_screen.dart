import '../models/http_exception.dart';
import '../providers/user_provider.dart';
import '../screens/rest_password_screen.dart';
import '../screens/sign_up_screen.dart';
import '../widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../widgets/my_edit_text.dart';

class SignInScreen extends StatefulWidget {
  static const routeName = '/sign-in';

  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _passwordFocusNode = FocusNode();

  var _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _passwordFocusNode.dispose();

    super.dispose();
  }

  Future<void> submitData(BuildContext context) async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
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
    final password = _passwordController.text;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      var userProv = Provider.of<UserProvider>(context, listen: false);
      await userProv.signIn(email, password);
      await userProv.fetchProfile();
      Navigator.of(context).pop();

      /* Navigator.of(context).pushReplacementNamed(MainScreen.routeName,
          arguments: {'signed': 'true'}); */
    } on HttpException catch (error) {
      var errorMessage = 'authentication_failed'.tr;
      if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'EMAIL_NOT_FOUND'.tr;
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'INVALID_PASSWORD'.tr;
      } else if (error.toString().contains('ERROR')) {
        errorMessage = 'error_message'.tr;
      }
      showErrorDialog(errorMessage, context);
    } catch (error) {
      var errorMessage = 'error_message'.tr;
      if (mounted) {
        showErrorDialog(errorMessage, context);
      }
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        height: deviceSize.height,
        width: deviceSize.width,
        child: SingleChildScrollView(
          child: SizedBox(
            height: deviceSize.height,
            width: deviceSize.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                    top: 30,
                    right: 8,
                  ),
                  margin: const EdgeInsets.only(
                      left: 20, right: 20, top: 8, bottom: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'sign_in'.tr,
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
                MyEditText(
                    title: 'email_or_phone'.tr,
                    fontFamily: 'OpenSans',
                    textDirection: TextDirection.ltr,
                    enabled: !_isLoading,
                    textController: _emailController,
                    onSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_passwordFocusNode)),
                MyEditText(
                    title: 'password'.tr,
                    fontFamily: 'OpenSans',
                    textDirection: TextDirection.ltr,
                    enabled: !_isLoading,
                    obscureText: true,
                    textFocusNode: _passwordFocusNode,
                    textController: _passwordController,
                    onSubmitted: (_) => submitData(context)),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(RestPasswordScreen.routeName);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      bottom: 8,
                      left: 8,
                      right: 8,
                    ),
                    margin:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                    child: Text(
                      'forget_password'.tr,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontSize: 18),
                    ),
                  ),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    )),
                  )
                else
                  Container(
                    padding: const EdgeInsets.only(bottom: 8, top: 10),
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 8, bottom: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0)),
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                              ),
                              child: Text(
                                'cancel'.tr,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0)),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              submitData(context);
                            },
                            style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(0)),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0)),
                              ),
                              child: Text(
                                'log_in'.tr,
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
                      'no_account'.tr,
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
                        Navigator.of(context)
                            .pushReplacementNamed(SignUpScreen.routeName);
                      },
                      child: Text(
                        'sign_up'.tr,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
