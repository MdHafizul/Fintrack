import 'package:expensetracker/pages/authentication/loginpage.dart';
import 'package:expensetracker/pages/homepagetest.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          _buildBackgroundImage(),
          // Centered image of the man
          _buildManImage(),
          // Main text
          _buildMainText(),
          // Get Started button
          _buildGetStartedButton(context),
          // Sign In text link
          _buildSignInText(context),
        ],
      ),
    );
  }

  // Widget for the background image
  Widget _buildBackgroundImage() {
    return Image.asset(
      'assets/images/background.png',
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }

  // Widget for the man image centered
  Widget _buildManImage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: Center(
        child: Image.asset(
          'assets/images/man.png',
          width: 350,
          height: 550,
        ),
      ),
    );
  }

  // Widget for the main text
  Widget _buildMainText() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 125.0),
        child: const Text(
          "Spend Smarter\nSave More",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF438883),
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Widget for the Get Started button
  Widget _buildGetStartedButton(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the next screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => Homepagetest(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF438883),
            padding: const EdgeInsets.symmetric(horizontal: 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            "Get Started",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }

  // Widget for the Sign In text
  Widget _buildSignInText(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Already have an account?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 12,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to the login page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text(
                "Sign In",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
