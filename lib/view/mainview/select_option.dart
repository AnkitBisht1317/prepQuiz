import 'package:flutter/material.dart';
import 'package:prepquiz/view/mainview/professor_information.dart';
import 'package:prepquiz/view/mainview/student_information.dart';

class SelectOption extends StatefulWidget {
  const SelectOption({super.key});

  @override
  State<SelectOption> createState() => _SelectOptionState();
}

class _SelectOptionState extends State<SelectOption> {
  String? userType;
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

                    // Option Selector Row
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUserTypeButton(
                          context,
                          title: 'College Student',
                          isSelected: userType == 'student',
                          onTap: () => setState(() => userType = 'student'),
                        ),
                        SizedBox(height: height * 0.07),
                        _buildUserTypeButton(
                          context,
                          title: 'College Professor',
                          isSelected: userType == 'professor',
                          onTap: () => setState(() => userType = 'professor'),
                        ),
                      ],
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
                          if (userType == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select an option first."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            if (userType == 'student') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const StudentInformation(),
                                ),
                              );
                            } else if (userType == 'professor') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const ProfessorInformation(),
                                ),
                              );
                            }
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
        'Personal Details',
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

  Widget _buildUserTypeButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: width * 0.035),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C6EFF) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF6C6EFF) : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: width * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
