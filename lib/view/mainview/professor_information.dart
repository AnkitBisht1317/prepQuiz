import 'package:flutter/material.dart';
import 'package:prepquiz/view/admin/admin_home_screen.dart';

class ProfessorInformation extends StatefulWidget {
  const ProfessorInformation({super.key});

  @override
  State<ProfessorInformation> createState() => _ProfessorInformationState();
}

class _ProfessorInformationState extends State<ProfessorInformation> {
  final TextEditingController _teacherIdController = TextEditingController();
  final TextEditingController _teacherPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          _buildHeader(height, width),
          Padding(
            padding: EdgeInsets.only(top: height * 0.3),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.06,
                  vertical: height * 0.015,
                ),
                child: Column(
                  children: [
                    _buildHeaderRow(width),
                    SizedBox(height: height * 0.09),

                    // Input fields
                    TextField(
                      controller: _teacherIdController,
                      decoration: InputDecoration(
                        labelText: 'Teacher ID',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    TextField(
                      controller: _teacherPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.06),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: height * 0.065,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF022150),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (_teacherIdController.text.isEmpty ||
                              _teacherPasswordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Please enter both ID and password.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Login details submitted."),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Navigate to HomeScreen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminHomeScreen(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'NEXT',
                          style: TextStyle(
                            fontSize: width * 0.045,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(double width) {
    return Center(
      child: Text(
        'Teacher Login',
        style: TextStyle(
          color: const Color(0xFF022150),
          fontSize: width * 0.06,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader(double height, double width) {
    return Container(
      height: height * 0.35,
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6CA8CB), Color(0xFF022150), Color(0xFF022150)],
          begin: Alignment.bottomLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(top: height * 0.1, bottom: height * 0.1),
          child: Image.asset(
            'assets/logo.png',
            alignment: Alignment.center,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
