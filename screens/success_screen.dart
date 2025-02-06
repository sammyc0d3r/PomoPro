import 'package:flutter/material.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // App Logo
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      const TextSpan(text: 'PO'),
                      TextSpan(
                        text: '\nMO',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
            // Success Message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You did it!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SUCCESSFULLY CREATED ACCOUNT',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.5,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Chef Illustration
            Stack(
              alignment: Alignment.center,
              children: [
                // Sparkle elements
                Positioned(
                  top: 20,
                  right: 100,
                  child: Transform.rotate(
                    angle: 45 * 3.14159 / 180,
                    child: const Icon(
                      Icons.star,
                      color: Colors.black,
                      size: 14,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 80,
                  child: Transform.rotate(
                    angle: 45 * 3.14159 / 180,
                    child: const Icon(
                      Icons.star,
                      color: Colors.black,
                      size: 14,
                    ),
                  ),
                ),
                // Chef image
                Image.asset(
                  'assets/images/chef.png',
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const Spacer(),
            // Continue Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
