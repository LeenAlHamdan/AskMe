import 'package:ask_me/screens/sign_in_screen.dart';

import '../models/http_exception.dart';
import '../providers/user_provider.dart';
import '../widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../widgets/my_edit_text.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = '/sign-up';

  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _mobileNumController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String phone = '';

  final _mobileNumFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  var _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileNumController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _mobileNumFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  Future<void> submitData(BuildContext context) async {
    if (_fullNameController.text.isEmpty ||
        _mobileNumController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    if (_fullNameController.text.length < 3) {
      var errorMessage = 'name_is_too_short'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    if (_passwordController.text.compareTo(_confirmPasswordController.text) !=
        0) {
      var errorMessage = 'not_matching_passwords'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    /* RegExp exp = RegExp(
        '^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@\$!%*?&])[A-Za-z\\d@\$!%*?&]{8,}\$');
    String str = _passwordController.text;
    final m = exp.matchAsPrefix(str);
 */
    if (_passwordController.text.length < 8) {
      var errorMessage = 'WEAK_PASSWORD'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    if (!_emailController.text.removeAllWhitespace.isEmail) {
      var errorMessage = 'INVALID_EMAIL'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    if (!_mobileNumController.text.removeAllWhitespace.isPhoneNumber) {
      var errorMessage = 'INVALID_PHONE_NUMBER'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }
    final email = _emailController.text.removeAllWhitespace;
    final fullName = _fullNameController.text;
    final password = _passwordController.text;
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await Provider.of<UserProvider>(context, listen: false).signup(
        email,
        password,
        fullName,
        phone,
      );
      Navigator.of(context).pop();

      /* Navigator.of(context).pushReplacementNamed(MainScreen.routeName,
          arguments: {'signed': 'true'}); */
    } on HttpException catch (error) {
      var errorMessage = 'authentication_failed'.tr;
      errorMessage = error.toString().tr;
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'join_us'.tr,
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
                    title: 'full_name'.tr,
                    enabled: !_isLoading,
                    autofocus: true,
                    textController: _fullNameController,
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_emailFocusNode)),
                MyEditText(
                    title: 'email'.tr,
                    fontFamily: 'OpenSans',
                    textDirection: TextDirection.ltr,
                    enabled: !_isLoading,
                    textController: _emailController,
                    textFocusNode: _emailFocusNode,
                    onSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_mobileNumFocusNode)),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    padding: const EdgeInsets.only(
                      bottom: 8,
                      left: 8,
                      right: 8,
                    ),
                    margin: const EdgeInsets.only(
                        left: 20, right: 20, top: 8, bottom: 30),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IntlPhoneField(
                      decoration: InputDecoration(
                          labelText: 'mobile_num'.tr,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor)),
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                          counter: null,
                          counterText: ''),
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 14,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      initialCountryCode: 'SY',
                      enabled: !_isLoading,
                      autovalidateMode: AutovalidateMode.disabled,
                      controller: _mobileNumController,
                      focusNode: _mobileNumFocusNode,
                      onChanged: (ph) {
                        phone = ph.completeNumber;
                      },
                      onSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_passwordFocusNode),
                    ),
                  ),
                ),
                MyEditText(
                    title: 'password'.tr,
                    fontFamily: 'OpenSans',
                    enabled: !_isLoading,
                    textDirection: TextDirection.ltr,
                    textController: _passwordController,
                    textFocusNode: _passwordFocusNode,
                    obscureText: true,
                    onSubmitted: (_) => FocusScope.of(context)
                        .requestFocus(_confirmPasswordFocusNode)),
                MyEditText(
                    title: 'confirm_password'.tr,
                    fontFamily: 'OpenSans',
                    enabled: !_isLoading,
                    textController: _confirmPasswordController,
                    textFocusNode: _confirmPasswordFocusNode,
                    obscureText: true,
                    textDirection: TextDirection.ltr,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => submitData(context)),
                if (_isLoading)
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
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
                                'create'.tr,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'have_account'.tr,
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
                              .pushReplacementNamed(SignInScreen.routeName);
                        },
                        child: Text(
                          'sign_in'.tr,
                          style:
                              Theme.of(context).textTheme.headline6!.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
