import 'package:flutter/material.dart';
import 'login_page.dart';

class AccountCreatedPage extends StatelessWidget {
  const AccountCreatedPage({super.key});

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
                        'Account Created!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B7FFF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Welcome to Task.y.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 64),

                      // Success Illustration
                      Center(
                        child: SizedBox(
                          width: 180,
                          height: 180,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Flowers
                              Positioned(
                                bottom: 0,
                                left: 20,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // First flower
                                    Column(
                                      children: [
                                        Container(
                                          width: 48, height: 48,
                                          decoration: const BoxDecoration(color: Color(0xFF5B7FFF), shape: BoxShape.circle),
                                          alignment: Alignment.center,
                                          child: Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFF4A6FEE), shape: BoxShape.circle)),
                                        ),
                                        Container(width: 4, height: 64, color: const Color(0xFF5B7FFF)),
                                        Container(width: 12, height: 8, decoration: BoxDecoration(color: const Color(0xFF5B7FFF), borderRadius: BorderRadius.circular(4))),
                                      ],
                                    ),
                                    const SizedBox(width: 32),
                                    // Second flower (larger)
                                    Column(
                                      children: [
                                        Container(
                                          width: 56, height: 56,
                                          decoration: const BoxDecoration(color: Color(0xFF5B7FFF), shape: BoxShape.circle),
                                          alignment: Alignment.center,
                                          child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF4A6FEE), shape: BoxShape.circle)),
                                        ),
                                        Container(width: 4, height: 80, color: const Color(0xFF5B7FFF)),
                                        Container(width: 16, height: 8, decoration: BoxDecoration(color: const Color(0xFF5B7FFF), borderRadius: BorderRadius.circular(4))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Person
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Column(
                                  children: [
                                    Container(width: 32, height: 32, decoration: const BoxDecoration(color: Color(0xFF333333), shape: BoxShape.circle)),
                                    const SizedBox(height: 4),
                                    Container(width: 24, height: 32, decoration: const BoxDecoration(color: Color(0xFF333333), borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)))),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(width: 8, height: 16, decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(4))),
                                        const SizedBox(width: 8),
                                        Container(width: 8, height: 16, decoration: BoxDecoration(color: const Color(0xFF333333), borderRadius: BorderRadius.circular(4))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Small decorative flower
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: Column(
                                  children: [
                                    Container(width: 24, height: 24, decoration: const BoxDecoration(color: Color(0xFF5B7FFF), shape: BoxShape.circle)),
                                    Container(width: 4, height: 32, color: const Color(0xFF5B7FFF)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Success Message
                      const Text(
                        'Your account has been created',
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

