import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../home/presentation/pages/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;

  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut)
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeInOut)
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _buttonController, curve: Curves.bounceOut)
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 500));
    _logoController.forward();

    await Future.delayed(Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(Duration(milliseconds: 600));
    _buttonController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.metallicGreenGradient),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoAnimation.value,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.trending_up,
                            size: 50,
                            color: AppColors.iosBlue,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // iOS style animated title
                          AnimatedTextKit(
                            animatedTexts: [
                              TypewriterAnimatedText(
                                'Welcome to PTA',
                                textStyle: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600, // iOS style font weight
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                speed: Duration(milliseconds: 150),
                              ),
                            ],
                            totalRepeatCount: 1,
                          ),

                          SizedBox(height: 16),

                          // Subtitle with iOS typography
                          FadeTransition(
                            opacity: _textAnimation,
                            child: Text(
                              AppStrings.welcomeSubtitle,
                              style: TextStyle(
                                fontSize: 17, // iOS standard body size
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.8),
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 40),

                          // Feature highlights with iOS icons
                          FadeTransition(
                            opacity: _textAnimation,
                            child: Column(
                              children: [
                                _buildFeatureItem(Icons.pie_chart_outline, 'Track Performance'),
                                SizedBox(height: 12),
                                _buildFeatureItem(Icons.trending_up, 'Real-time Data'),
                                SizedBox(height: 12),
                                _buildFeatureItem(Icons.security, 'Secure & Reliable'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Regular sized iOS style button
              Expanded(
                flex: 1,
                child: AnimatedBuilder(
                  animation: _buttonAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonAnimation.value,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 60),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50, // Regular iOS button height
                          child: ElevatedButton(
                            onPressed: () {
                              Get.to(() => HomeScreen(),
                                  transition: Transition.cupertino,
                                  duration: Duration(milliseconds: 400));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.iosBlue,
                              elevation: 0, // iOS style - no elevation
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // iOS corner radius
                              ),
                            ),
                            child: Text(
                              AppStrings.getStarted,
                              style: TextStyle(
                                fontSize: 17, // iOS standard button text size
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
        SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}
