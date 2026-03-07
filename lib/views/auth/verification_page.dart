import 'package:flutter/material.dart';
import '../../services/email_service.dart';
import 'set_new_password_page.dart';
import 'login_page.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  final String actualCode;
  const VerificationPage({super.key, required this.email, required this.actualCode});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  bool _isLoading = false;

  void _verifyCode() {
    String code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter the complete 4-digit code.")));
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Verify against passed code
    bool ok = (code == widget.actualCode);
    
    setState(() => _isLoading = false);
    
    if (ok) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => SetNewPasswordPage(email: widget.email)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid verification code!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
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
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF5B7FFF)),
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
                        'Verification',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B7FFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter the code to continue.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Illustration
                      Center(
                        child: Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EAFF),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Document
                              Container(
                                width: 64,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5B7FFF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(height: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                                    const SizedBox(height: 4),
                                    Container(height: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                                    const SizedBox(height: 4),
                                    FractionallySizedBox(
                                      widthFactor: 0.75,
                                      child: Container(height: 4, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                                    ),
                                  ],
                                ),
                              ),
                              // Person
                              Positioned(
                                right: -24,
                                top: 20,
                                child: Column(
                                  children: [
                                    Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFFFFC0CB), shape: BoxShape.circle)),
                                    const SizedBox(height: 4),
                                    Container(width: 24, height: 32, decoration: const BoxDecoration(color: Color(0xFFFFC0CB), borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)))),
                                  ],
                                ),
                              ),
                              // Magnifying glass
                              Positioned(
                                top: -8,
                                right: -8,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF5B7FFF), width: 4),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Email Display
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(color: Color(0xFF374151), fontSize: 14, height: 1.5),
                          children: [
                            const TextSpan(text: 'We sent a code to\n'),
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Code Input
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          return Container(
                            width: 56, // w-14
                            height: 56, // h-14
                            margin: const EdgeInsets.symmetric(horizontal: 6), // gap-3 / 2
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                              onChanged: (value) => _onChanged(value, index),
                              decoration: InputDecoration(
                                counterText: '',
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFD1D5DB), width: 2), // border-gray-300
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF5B7FFF), width: 2),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),

                      // Continue Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _verifyCode,
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
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 24),

                      // Resend Code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't receive the code? ",
                            style: TextStyle(color: Color(0xFF4B5563), fontSize: 14),
                          ),
                          GestureDetector(
                            onTap: () async {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Resending email with code...")));
                              final errorMessage = await EmailService.sendOTP(widget.email, widget.actualCode);
                              if (!mounted) return;
                              if (errorMessage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("New email sent successfully!")));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $errorMessage")));
                              }
                            },
                            child: const Text(
                              'Send Again',
                              style: TextStyle(
                                color: Color(0xFF5B7FFF),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Back to Login
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                        },
                        icon: const Icon(Icons.arrow_back, size: 16, color: Color(0xFF374151)),
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

