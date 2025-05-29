import 'package:flutter/material.dart';
import 'package:prepquiz/view/mainview/select_option.dart';

class GetStart extends StatefulWidget {
  const GetStart({super.key});

  @override
  State<GetStart> createState() => _GetStartState();
}

class _GetStartState extends State<GetStart> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: height * 0.35,
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6CA8CB),
                  Color(0xFF022150),
                  Color(0xFF022150),
                ],
                begin: Alignment.bottomLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: height * 0.15,
                left: width * 0.0,
                bottom: width * 0.15,
              ),
              child: Image.asset(
                'assets/logo.png',
                alignment: Alignment.center,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: height * 0.3),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(30),
                  topLeft: Radius.circular(30),
                ),
                color: Colors.white,
              ),
              height: height * 0.9,
              width: width,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Get Started Free text (same as before)
                    const Center(
                      child: Text(
                        'Get Started Free.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2A5C),
                        ),
                      ),
                    ),

                    const SizedBox(height: 70),

                    // Welcome to PrepQuiz (bigger text)
                    const Center(
                      child: Text(
                        'Welcome to PrepQuiz',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A2A5C),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Placement Quiz slogan (3 lines)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: const Text(
                        'Your gateway to success.\n'
                        'Practice with top placement questions.\n'
                        'Boost your career with confidence.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // VERIFY button (unchanged functionality)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0A2A5C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SelectOption(),
                              ),
                            );
                          },
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
