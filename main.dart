import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/success_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/success': (context) => const SuccessScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Sparkle elements positioned around
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                right: MediaQuery.of(context).size.width * 0.2,
                child: _buildSparkle(),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.1,
                left: MediaQuery.of(context).size.width * 0.15,
                child: _buildSparkle(),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.3,
                left: MediaQuery.of(context).size.width * 0.1,
                child: _buildSparkle(),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.25,
                right: MediaQuery.of(context).size.width * 0.15,
                child: _buildSparkle(),
              ),
              // Main content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  const Text(
                    'Better way\nto manage',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  // Character illustration
                  Center(
                    child: Image.asset(
                      'assets/images/character.png',
                      height: MediaQuery.of(context).size.height * 0.4,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(200, 48),
                      ),
                      child: const Text(
                        'GET STARTED',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSparkle() {
    return Transform.rotate(
      angle: 45 * 3.14159 / 180,
      child: const Icon(
        Icons.star,
        color: Colors.black,
        size: 14,
      ),
    );
  }
}
