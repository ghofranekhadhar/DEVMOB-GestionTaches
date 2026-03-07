import 'dart:math';
import 'package:flutter/material.dart';
import '../../services/email_service.dart';
import 'verification_page.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final input = _emailController.text.trim().toLowerCase();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email address.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Generate random 4 digit code
    final generatedCode = (1000 + Random().nextInt(9000)).toString();

    // Use the real SMTP Mailer Service
    final errorMessage = await EmailService.sendOTP(input, generatedCode);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("A real email with the 4-digit code has been sent!"),
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              VerificationPage(email: input, actualCode: generatedCode),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: $errorMessage"),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header (Back Button)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF5B7FFF),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    style: IconButton.styleFrom(
                      hoverColor: Colors.grey.shade100,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
                const SizedBox(height: 80),

                // Title
                const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B7FFF),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'No worries, We got you.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                ),
                const SizedBox(height: 24),

                // Illustration Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EAFF),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Illustration (Person thinking)
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5B7FFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Positioned(
                            top: -8,
                            right: -8,
                            child: Text('❓', style: TextStyle(fontSize: 32)),
                          ),
                          const Positioned(
                            top: 0,
                            right: 48,
                            child: Text('💭', style: TextStyle(fontSize: 24)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5B7FFF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "We'll send you code to reset it.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151), // text-gray-700
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Method Toggle removed
                const SizedBox(height: 24),

                // Input Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Enter email address",
                    hintStyle: const TextStyle(
                      color: Color(0xFF9CA3AF),
                    ), // gray-400
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD1D5DB),
                      ), // gray-300
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF5B7FFF),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Send Code Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B7FFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Send Reset Link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 48),

                // Back to Login
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 16,
                    color: Color(0xFF374151),
                  ),
                  label: const Text(
                    'Back to log in?',
                    style: TextStyle(color: Color(0xFF374151), fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF5B7FFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
