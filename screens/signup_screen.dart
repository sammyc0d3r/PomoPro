import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Password validation rules
  bool _hasMinLength = false;
  bool _hasLetterAndNumber = false;
  bool _hasSpecialChar = false;

  void _validatePassword(String password) {
    setState(() {
      _hasMinLength = password.length >= 9;
      _hasLetterAndNumber = password.contains(RegExp(r'[A-Za-z]')) && 
                           password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
  }

  bool _isPasswordValid() {
    return _hasMinLength && _hasLetterAndNumber && _hasSpecialChar;
  }

  bool _passwordsMatch() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  Future<void> _handleSignup() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    if (!_isPasswordValid()) {
      setState(() {
        _errorMessage = 'Password does not meet all requirements';
      });
      return;
    }

    if (!_passwordsMatch()) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signup(
        _emailController.text,
        _passwordController.text,
      );

      if (mounted) {
        if (result['success']) {
          Navigator.of(context).pushReplacementNamed('/success');
        } else {
          setState(() {
            _errorMessage = result['message'];
          });
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // App Logo
              Center(
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
              const SizedBox(height: 60),
              // Sign up Text
              const Text(
                'Sign up',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EMAIL ADDRESS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      hintText: 'example@gmail.com',
                      border: UnderlineInputBorder(),
                      hintStyle: TextStyle(color: Colors.black38),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PASSWORD',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: _validatePassword,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  // Password requirements
                  _PasswordRequirement(
                    text: 'MUST CONTAIN AT LEAST 9 CHARACTERS',
                    isMet: _hasMinLength,
                  ),
                  _PasswordRequirement(
                    text: 'MUST CONTAIN LETTERS AND NUMBERS',
                    isMet: _hasLetterAndNumber,
                  ),
                  _PasswordRequirement(
                    text: 'MUST CONTAIN A SPECIAL CHARACTER (!@#\$%^&*)',
                    isMet: _hasSpecialChar,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Confirm Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REPEAT PASSWORD',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      border: const UnderlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
              const Spacer(),
              // Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(12),
                      shape: const CircleBorder(),
                    ),
                  ),
                  // Sign up Button
                  _isLoading
                      ? const CircularProgressIndicator()
                      : FloatingActionButton(
                          onPressed: _handleSignup,
                          backgroundColor: Colors.black,
                          child: const Icon(Icons.arrow_forward, color: Colors.white),
                        ),
                ],
              ),
              const SizedBox(height: 20),
              // Login Link
              Center(
                child: Column(
                  children: [
                    const Text(
                      'ALREADY HAVE AN ACCOUNT?',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: const Text(
                        'LOG IN',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordRequirement extends StatelessWidget {
  final String text;
  final bool isMet;

  const _PasswordRequirement({
    required this.text,
    required this.isMet,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400]!,
                width: 1,
              ),
            ),
            child: isMet
                ? const Icon(
                    Icons.check,
                    size: 10,
                    color: Colors.black,
                  )
                : null,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
