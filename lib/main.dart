import 'dart:async';
import 'dart:io';

import 'package:ask_me/providers/consultancy_provider.dart';
import 'package:ask_me/providers/question_provider.dart';
import 'package:ask_me/providers/specialist_provider.dart';
import 'package:ask_me/providers/specialization_provider.dart';
import 'package:ask_me/providers/user_provider.dart';
import 'package:ask_me/screens/main_screen.dart';
import 'package:ask_me/screens/show_fields_screen.dart';
import 'package:ask_me/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_string.dart';
import 'providers/answer_provider.dart';
import 'providers/field_provider.dart';
import 'screens/rest_password_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
    ),
    ChangeNotifierProvider(
      create: (_) => FieldProvider(),
    ),
    ChangeNotifierProvider(
      create: (_) => SpecializationProvider(),
    ),
    ChangeNotifierProvider(
      create: (_) => SpecialistProvider(),
    ),
    ChangeNotifierProvider(
      create: (_) => QuestionProvider(),
    ),
    ChangeNotifierProvider(
      create: (_) => AnswerProvider(),
    ),
    ChangeNotifierProvider(
      create: (_) => ConsultancyProvider(),
    ),
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List locales = [
    {'name': 'English', 'locale': const Locale('en')},
    {'name': 'Arabic', 'locale': const Locale('ar')},
  ];
  bool isInit = true;
  bool showPrivacyPlocity = false;

  final String defaultLocale = Platform.localeName;
  updateLanguage(Locale locale) {
    Get.back();
    Get.updateLocale(locale);
    SharedPreferences.getInstance().then((value) {
      value.setString('Locale', locale.languageCode);
    });
  }

  Future<void> locale() async {
    final prefs = await SharedPreferences.getInstance();
    Locale locale = prefs.containsKey('Locale')
        ? prefs.getString('Locale')!.contains('ar')
            ? const Locale('ar')
            : const Locale('en')
        : defaultLocale.contains('ar')
            ? const Locale('ar')
            : const Locale('en');

    updateLanguage(locale);
    return;
  }

  @override
  void initState() {
    locale();
    super.initState();
  }

  Future<void> getData(
    BuildContext context,
  ) async {
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final consultancyProvider =
          Provider.of<ConsultancyProvider>(context, listen: false);

      final fieldProv = Provider.of<FieldProvider>(context, listen: false);
      final specializationProvider =
          Provider.of<SpecializationProvider>(context, listen: false);

      final specialistProvider =
          Provider.of<SpecialistProvider>(context, listen: false);
      if (!userProv.userIsSignd()) {
        await userProv.tryAutoLogin();
      } else {
        await userProv.fetchProfile();
        await consultancyProvider.fetchAndSetUnseenMessages(userProv.token, 0);
      }

      await fieldProv.fetchAndSetFields(userProv.token, 0);
      await specialistProvider.fetchAndSetSpecialists(userProv.token, 0);
      await specializationProvider.fetchAndSetSpecializations(
          userProv.token, 0);
      await Future.delayed(const Duration(seconds: 1));
    } on HttpException catch (_) {
      throw const HttpException('error');
    } catch (error) {
      rethrow;
    }
  }

  var primaryColor = const Color(0xFF2f3239);
  var primaryDark = const Color(0xFFff7361);
  var backgroundColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ask Me',
      translations: LocaleString(),
      theme: ThemeData(
          fontFamily:
              Get.locale == const Locale('en') ? 'OpenSans' : 'DroidKufi',
          primaryColorDark: primaryDark,
          focusColor: Colors.grey,
          backgroundColor: backgroundColor,
          scaffoldBackgroundColor: backgroundColor,
          canvasColor: Colors.grey[200],
          cardColor: backgroundColor,
          dialogBackgroundColor: backgroundColor,
          textTheme: TextTheme(
            headline6: TextStyle(
                color: primaryColor, fontSize: 18, fontWeight: FontWeight.bold),
            headline1: TextStyle(color: primaryDark, fontSize: 14),
            bodyText1: TextStyle(color: primaryDark, fontSize: 16),
            bodyText2: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            secondary: Colors.black,
          ),
          dividerColor: Colors.black26,
          primaryColor: primaryColor,
          secondaryHeaderColor: primaryDark,
          appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
              color: primaryDark,
            ),
          )),
      home: FutureBuilder(
          future: getData(
            context,
          ),
          builder: (ctx, authResultSnapshot) {
            return authResultSnapshot.connectionState == ConnectionState.waiting
                ? const SplashScreen()
                : const MainScreen();
          }),
      routes: {
        //  MainScreen.routeName: (ctx) => const MainScreen(),
        SignInScreen.routeName: (ctx) => const SignInScreen(),
        SignUpScreen.routeName: (ctx) => const SignUpScreen(),
        ShowFieldsScreen.routeName: (ctx) => const ShowFieldsScreen(),
        RestPasswordScreen.routeName: (ctx) => const RestPasswordScreen(),
      },
    );
  }
}
