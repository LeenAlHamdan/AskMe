import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );

  late final _controller2 = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  final Widget _animatedArabicText = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    key: const ValueKey(1),
    children: const [
      Image(
        alignment: Alignment.center,
        fit: BoxFit.contain,
        width: 120,
        image: AssetImage('assets/images/logo_text_ar.png'),
      ),
    ],
  );

  final Widget _animatedEnglishText = Column(
    key: const ValueKey(2),
    children: const [
      Image(
        alignment: Alignment.center,
        fit: BoxFit.contain,
        width: 120,
        image: AssetImage('assets/images/logo_text_en.png'),
      ),
    ],
  );

  late Widget _animatedText;

  bool breaker = false;
  late Timer timer;

  @override
  void dispose() {
    _controller.dispose();
    _controller2.dispose();

    breaker = true;
    timer.cancel();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _animatedText = _animatedArabicText;

    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!breaker) {
        if (mounted) {
          setState(() {
            if (_animatedText == _animatedArabicText) {
              _animatedText = _animatedEnglishText;
            } else {
              _animatedText = _animatedArabicText;
            }
          });
        }
      } else {
        timer.cancel();
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
    _controller2.forward();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _animation,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.scaleDown,
                    width: 150,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                LoadingBouncingLine.circle(
                  backgroundColor: Theme.of(context).primaryColorDark,
                ),
                /*             Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: FadeTransition(
                    opacity: _animation2,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) => SizeTransition(
                        sizeFactor: animation,
                        child: Center(child: child),
                      ),
                      child: _animatedText,
                    ),
                  ),
                ), */
              ],
            ),
          ),
        ),
      ),
    );
  }
}
