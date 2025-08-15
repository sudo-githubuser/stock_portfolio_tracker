import 'package:flutter/foundation.dart';
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
  late AnimationController _backgroundController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonController;
  late AnimationController _featuresController;
  late AnimationController _marketIconController;

  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;
  late Animation<double> _featuresAnimation;
  late Animation<double> _circleAnimation;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

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

    _featuresController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _marketIconController = AnimationController(
      duration: Duration(milliseconds: 2500),
      vsync: this,
    );

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut)
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

    _featuresAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _featuresController, curve: Curves.easeOutBack)
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _marketIconController, curve: Curves.easeInOut)
    );

    _arrowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _marketIconController,
          curve: Interval(0.0, 0.6, curve: Curves.easeOutBack),
        )
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Start background animation first
    _backgroundController.forward();

    await Future.delayed(Duration(milliseconds: 800));
    _logoController.forward();

    await Future.delayed(Duration(milliseconds: 800));
    _textController.forward();

    // Start market icon animation
    _marketIconController.forward();

    await Future.delayed(Duration(milliseconds: 600));
    _featuresController.forward();

    await Future.delayed(Duration(milliseconds: 400));
    _buttonController.forward();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Coming Soon!',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToHome() {
    Get.to(() => HomeScreen(),
        transition: Transition.cupertino,
        duration: Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    _featuresController.dispose();
    _marketIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomLeft,
                radius: _backgroundAnimation.value * 1.5,
                colors: _backgroundAnimation.value < 0.5
                    ? [Colors.black, Colors.black]
                    : [
                  Color(0xFF1B5E20), // Dark green
                  Colors.green.shade900,
                  Color(0xFF0D1F14)
                ],
                stops: _backgroundAnimation.value < 0.5
                    ? [0.0, 1.0]
                    : [0.0, 0.6, 1.0],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // Title and Market Icon Section
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App name
                          AnimatedBuilder(
                            animation: _logoAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoAnimation.value,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Track O ',
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Folio',
                                        style: TextStyle(
                                          fontSize: 38,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF4CAF50), // Green color
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 30),

                          // Animated Stock Market Icon
                          AnimatedBuilder(
                            animation: _textAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _textAnimation.value,
                                child: _buildAnimatedMarketIcon(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Feature Cards Section
                    Expanded(
                      flex: 2,
                      child: AnimatedBuilder(
                        animation: _featuresAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _featuresAnimation.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildFeatureCard(
                                  icon: Icons.bar_chart_rounded,
                                  title: 'Real-time Analytics',
                                  description: 'Track your portfolio performance with live data and advanced charting tools.',
                                ),

                                SizedBox(height: 16),

                                _buildFeatureCard(
                                  icon: Icons.pie_chart_rounded,
                                  title: 'Portfolio Diversification',
                                  description: 'Visualize your asset allocation and optimize your investment strategy.',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Button Section
                    Expanded(
                      flex: 1,
                      child: AnimatedBuilder(
                        animation: _buttonAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _buttonAnimation.value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Google and Let's Go buttons
                                Row(
                                  children: [
                                    // Google button
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showComingSoon();
                                            Future.delayed(Duration(seconds: 2), _navigateToHome);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black87,
                                            elevation: 4,
                                            shadowColor: Colors.black.withOpacity(0.3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  'https://developers.google.com/identity/images/g-logo.png',
                                                ),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(width: 16),

                                    // Let's Go button
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: _navigateToHome,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Color(0xFF2E7D32),
                                            elevation: 4,
                                            shadowColor: Colors.black.withOpacity(0.3),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                          ),
                                          child: Text(
                                            "Let's Go",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 16),

                                // Sign up link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _showComingSoon();
                                        Future.delayed(Duration(seconds: 2), _navigateToHome);
                                      },
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          color: Color(0xFF81C784),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Color(0xFF81C784),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
        },
      ),
    );
  }

  Widget _buildAnimatedMarketIcon() {
    return Container(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Circle
          AnimatedBuilder(
            animation: _circleAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(100, 100),
                painter: CirclePainter(
                  progress: _circleAnimation.value,
                  color: Color(0xFF81C784),
                ),
              );
            },
          ),

          // Animated Arrow
          AnimatedBuilder(
            animation: _arrowAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - _arrowAnimation.value)),
                child: Transform.scale(
                  scale: _arrowAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: Colors.green.shade700,
                      size: 54,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Changed to greyish colors
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              // Greyish icon background
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Color(0xFF81C784),
              size: 20,
            ),
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[300], // Greyish title color
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[400], // Greyish description color
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the animated circle
class CirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  CirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Draw the animated circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start from top (-90 degrees in radians)
      2 * 3.14159 * progress, // Progress from 0 to full circle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
