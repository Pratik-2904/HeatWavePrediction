import 'package:demo_application/consts/presentation/mainScreen.dart';
import 'package:demo_application/consts/presentation/weatherScreen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Color?>? _colorAnimation;
  bool _showLogo = false;
  bool _fadeOut = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Quick transition
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _colorAnimation = ColorTween(
      begin: Colors.deepOrange, // Sunset Orange or Burnt Orange
      end: Colors.blueAccent, // Deep Blue
    ).animate(_controller!);

    // Start the color transition immediately
    Future.delayed(Duration(seconds: 0), () {
      setState(() {
        _showLogo = true;
      });
      _controller!.forward();

      // Fade out the logo and tagline after the transition
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          _fadeOut = true;
        });
        // Navigate to MainScreen with slide animation after fading out
        Future.delayed(Duration(seconds: 0), () {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration:
                  Duration(seconds: 1), // Duration of the slide transition
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MainScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0); // Slide from right to left
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        });
      });
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _colorAnimation!,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _colorAnimation!.value!,
                  _colorAnimation!.value!.withOpacity(0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: _showLogo
                  ? FadeTransition(
                      opacity: AlwaysStoppedAnimation(_fadeOut ? 0.0 : 1.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //   Container(
                          //     padding: const EdgeInsets.all(8.0),
                          //     decoration: BoxDecoration(
                          //       color: Colors.blueAccent,
                          //       borderRadius: BorderRadius.circular(20),
                          //     ),
                          //     child:
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: Image.asset(
                                  'assets/logo.jpeg',
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Harnessing AI for Climate Resilience",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // ),
                        ],
                      ),
                    )
                  : const SizedBox
                      .shrink(), // Empty container before logo appears
            ),
          );
        },
      ),
    );
  }
}
