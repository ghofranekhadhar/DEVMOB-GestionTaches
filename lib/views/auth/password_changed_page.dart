import 'package:flutter/material.dart';
import 'login_page.dart';

class PasswordChangedPage extends StatelessWidget {
  const PasswordChangedPage({super.key});

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
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
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
                        'Password Changed!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B7FFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'No hassle anymore.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 64),

                      // Success Illustration
                      Center(
                        child: Column(
                          children: [
                            // Checkmark circle
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF5B7FFF), width: 4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check, color: Color(0xFF5B7FFF), size: 80),
                                ),
                                // Decorative dots
                                Positioned(
                                  top: -16,
                                  left: -16,
                                  child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF5B7FFF), shape: BoxShape.circle)),
                                ),
                                Positioned(
                                  bottom: -8,
                                  right: -24,
                                  child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF5B7FFF), shape: BoxShape.circle)),
                                ),
                                Positioned(
                                  top: 0,
                                  right: -32,
                                  child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF5B7FFF), shape: BoxShape.circle)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // Person illustration
                            Column(
                              children: [
                                Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF333333), shape: BoxShape.circle)),
                                const SizedBox(height: 4),
                                Container(width: 32, height: 40, decoration: const BoxDecoration(color: Color(0xFF333333), borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)))),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(width: 8, height: 24, decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(4))),
                                    const SizedBox(width: 8),
                                    Container(width: 8, height: 24, decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(4))),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(width: 32, height: 8, decoration: BoxDecoration(color: const Color(0xFFFF6B6B), borderRadius: BorderRadius.circular(4))),
                                    const SizedBox(width: 12),
                                    Container(width: 32, height: 8, decoration: BoxDecoration(color: const Color(0xFFFF6B6B), borderRadius: BorderRadius.circular(4))),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Success Message
                      const Text(
                        'Your password has been reset',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Color(0xFF374151)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Successfully!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827)), // gray-900
                      ),
                      const SizedBox(height: 32),

                      // Continue Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B7FFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
            ),
          ),
      ),
    );
  }
}

