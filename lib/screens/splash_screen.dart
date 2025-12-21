import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 0.45).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _controller.forward();
    
    // Navigate to home screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF102217) : const Color(0xFFF6F8F7),
      body: Stack(
        children: [
          // Background gradient blurs
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF2BEE79) : const Color(0xFF2BEE79))
                        .withValues(alpha: isDark ? 0.1 : 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: -MediaQuery.of(context).size.width * 0.2,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? Colors.purple.shade900 : Colors.purple.shade300)
                        .withValues(alpha: isDark ? 0.2 : 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? Colors.blue.shade900 : Colors.blue.shade200)
                        .withValues(alpha: isDark ? 0.1 : 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container with rotation
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: -0.05, end: 0.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: value,
                      child: child,
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Glow effect
                      Container(
                        width: 144,
                        height: 144,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2BEE79).withValues(alpha: isDark ? 0.2 : 0.4),
                              blurRadius: 80,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      // Main icon card
                      Container(
                        width: 144,
                        height: 144,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2E22) : Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: isDark 
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.white.withValues(alpha: 0.6),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.dashboard,
                          size: 80,
                          color: Color(0xFF2BEE79),
                        ),
                      ),
                      // Sparkle badge
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white : Colors.black,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Transform.rotate(
                            angle: 0.2,
                            child: Icon(
                              Icons.auto_awesome,
                              color: isDark ? Colors.black : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Title
                Column(
                  children: [
                    Text(
                      'COLLAGE',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 1,
                          width: 32,
                          color: isDark 
                              ? Colors.grey.shade700 
                              : Colors.grey.shade300,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'STUDIO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            color: isDark 
                                ? Colors.grey.shade500 
                                : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 1,
                          width: 32,
                          color: isDark 
                              ? Colors.grey.shade700 
                              : Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bottom loading section
          Positioned(
            bottom: 64,
            left: 80,
            right: 80,
            child: Column(
              children: [
                // Progress bar
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDark 
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2BEE79),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2BEE79).withValues(alpha: 0.6),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Loading text
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.3, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: (0.4 + value * 0.6).clamp(0.0, 1.0),
                      child: child,
                    );
                  },
                  child: Text(
                    'LOADING ASSETS...',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                      color: isDark 
                          ? Colors.grey.shade600 
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Version
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v2.4.0',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark 
                      ? Colors.grey.shade700 
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
