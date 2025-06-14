import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'manage_categories_screen.dart';
import 'manage_quizes_Screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> _fetchStatistics() async {
    try {
      final categoriesSnapshot =
          await _firestore.collection('categories').get();
      final quizzesSnapshot = await _firestore.collection('quizzes').get();

      final latestQuizzes =
          await _firestore
              .collection('quizzes')
              .orderBy('createdAt', descending: true)
              .limit(5)
              .get();

      final categoryData = await Future.wait(
        categoriesSnapshot.docs.map((category) async {
          final quizQuery =
              await _firestore
                  .collection('quizzes')
                  .where('categoryId', isEqualTo: category.id)
                  .get();

          return {
            'name': category.data()['name'] ?? 'Unnamed',
            'count': quizQuery.docs.length,
          };
        }),
      );

      return {
        'totalCategories': categoriesSnapshot.docs.length,
        'totalQuizzes': quizzesSnapshot.docs.length,
        'latestQuizzes': latestQuizzes.docs,
        'categoryData': categoryData,
      };
    } catch (e) {
      print("Error in _fetchStatistics: $e");
      throw Exception('Failed to fetch statistics');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder(
        future: _fetchStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text('An error occurred'));
          }

          final Map<String, dynamic> stats = snapshot.data!;
          final List<dynamic> categoryData = stats['categoryData'];
          final List<QueryDocumentSnapshot> latestQuizzes =
              stats['latestQuizzes'];

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Admin",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Here's your application overview",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Categories',
                          stats['totalCategories'].toString(),
                          Icons.category_rounded,
                          AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Total Quizzes',
                          stats['totalQuizzes'].toString(),
                          Icons.quiz_rounded,
                          AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart_rounded,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Category Statistics',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: categoryData.length,
                            itemBuilder: (context, index) {
                              final category = categoryData[index];
                              final totalQuizzes = categoryData.fold<int>(
                                0,
                                (sum, item) => sum + (item['count'] as int),
                              );
                              final percentage =
                                  totalQuizzes > 0
                                      ? (category['count'] as int) /
                                          totalQuizzes *
                                          100
                                      : 0.0;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            category['name'] as String,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textPrimaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "${category['count']} ${(category['count'] as int) == 1 ? 'quiz' : 'quizzes'}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  AppTheme.textSecondaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.history_rounded,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Recent Activity',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: latestQuizzes.length,
                            itemBuilder: (context, index) {
                              final quiz =
                                  latestQuizzes[index].data()
                                      as Map<String, dynamic>;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.quiz_rounded,
                                              color: AppTheme.primaryColor,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  quiz['title'] ?? 'Untitled',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppTheme
                                                            .textPrimaryColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Created on ${quiz['createdAt'] != null ? _formatDate((quiz['createdAt'] as Timestamp).toDate()) : 'Unknown'}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme
                                                            .textSecondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Quiz Actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.textPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            crossAxisSpacing: 16,
                            children: [
                              _buildDashboardCard(
                                context,
                                'Quizzes',
                                Icons.quiz_rounded,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ManageQuizesScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildDashboardCard(
                                context,
                                'Categories',
                                Icons.category_rounded,
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ManageCategoriesScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
//
// import '../../theme/theme.dart';
// import 'manage_categories_screen.dart';
// import 'manage_quizes_Screen.dart';
//
// class AdminHomeScreen extends StatefulWidget {
//   const AdminHomeScreen({super.key});
//
//   @override
//   State<AdminHomeScreen> createState() => _AdminHomeScreenState();
// }
//
// class _AdminHomeScreenState extends State<AdminHomeScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<Map<String, dynamic>> _fetchStatistics() async {
//     final categoriesCount =
//         await _firestore.collection('categories').count().get();
//
//     final quizzesCount = await _firestore.collection('quizzes').count().get();
//
//     final latestQuizzes =
//         await _firestore
//             .collection('quizzes')
//             .orderBy('createdAt', descending: true)
//             .limit(5)
//             .get();
//
//     final categories = await _firestore.collection('categories').get();
//
//     final categoryData = await Future.wait(
//       categories.docs.map((category) async {
//         final quizCount =
//             await _firestore
//                 .collection('quizzes')
//                 .where('categoryId', isEqualTo: category.id)
//                 .count()
//                 .get();
//
//         return {
//           'name': category.data()['name'] as String,
//           'count': quizCount.count,
//         };
//       }),
//     );
//
//     return {
//       'totalCategories': categoriesCount.count,
//       'totalQuizzes': quizzesCount.count,
//       'latestQuizzes': latestQuizzes.docs,
//       'categoryData': categoryData,
//     };
//   }
//
//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
//
//   Widget _buildStatCard(
//     String title,
//     String value,
//     IconData icon,
//     Color color,
//   ) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(20), // ✅ Fixed incorrect padding syntax
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: color, size: 25),
//             ),
//             SizedBox(height: 16),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: AppTheme.textPrimaryColor,
//               ),
//             ),
//             SizedBox(height: 16),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: AppTheme.textSecondaryColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDashboardCard(
//     BuildContext context,
//     String title, // ✅ Fixed spelling
//     IconData icon,
//     VoidCallback onTap,
//   ) {
//     return Card(
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Padding(
//           padding: EdgeInsets.all(20), // 37:12  min check
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppTheme.primaryColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon, color: AppTheme.primaryColor, size: 32),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 title, // ✅ spelling fixed
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: AppTheme.textPrimaryColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppTheme.backgroundColor,
//         title: Text(
//           'Admin Dashboard',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         elevation: 0,
//       ),
//       body: FutureBuilder(
//         future: _fetchStatistics(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(
//               child: CircularProgressIndicator(color: AppTheme.primaryColor),
//             );
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('An error occurred'));
//           }
//
//           final Map<String, dynamic> stats = snapshot.data!; // ✅ type cast
//           final List<dynamic> categoryData =
//               stats['categoryData']; // ✅ fixed typo
//           final List<QueryDocumentSnapshot> latestQuizzes =
//               stats['latestQuizzes'];
//
//           return SafeArea(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "WelCome Admin",
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: AppTheme.textPrimaryColor,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     "Here\'s your application overview",
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: AppTheme.textSecondaryColor,
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildStatCard(
//                           'Total Categories',
//                           stats['totalCategories'].toString(),
//                           Icons.category_rounded,
//                           AppTheme.primaryColor,
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: _buildStatCard(
//                           'Total Quizzes',
//                           stats['totalQuizzes'].toString(),
//                           Icons.quiz_rounded,
//                           AppTheme.secondaryColor,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 24),
//                   Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.pie_chart_rounded,
//                                 color: AppTheme.primaryColor,
//                                 size: 24,
//                               ),
//                               SizedBox(width: 12),
//                               Text(
//                                 'Category Statistics',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: AppTheme.textPrimaryColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 20),
//                           ListView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             itemCount: categoryData.length,
//                             itemBuilder: (context, index) {
//                               final category = categoryData[index];
//                               final totalQuizzes = categoryData.fold<int>(
//                                 0,
//                                 (sum, item) => sum + (item['count'] as int),
//                               );
//                               final percentage =
//                                   totalQuizzes > 0
//                                       ? (category['count'] as int) /
//                                           totalQuizzes *
//                                           100
//                                       : 0.0;
//                               return Padding(
//                                 padding: EdgeInsets.only(bottom: 16),
//                                 child: Row(
//                                   children: [
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             category['name'] as String,
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w500,
//                                               color: AppTheme.textPrimaryColor,
//                                             ),
//                                           ),
//                                           SizedBox(height: 5),
//                                           Text(
//                                             "${category['count']} ${(category['count'] as int) == 1 ? 'quiz' : 'quizzes'}",
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               color:
//                                                   AppTheme.textSecondaryColor,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     Container(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: 12,
//                                         vertical: 6,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: AppTheme.primaryColor
//                                             .withOpacity(0.1),
//                                         borderRadius: BorderRadius.circular(20),
//                                       ),
//                                       child: Text(
//                                         '${percentage.toStringAsFixed(1)}%',
//                                         style: TextStyle(
//                                           color: AppTheme.primaryColor,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.history_rounded,
//                                 color: AppTheme.primaryColor,
//                                 size: 24,
//                               ),
//                               SizedBox(width: 12),
//                               Text(
//                                 'Recent Activity',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: AppTheme.textPrimaryColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 20),
//                           ListView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(),
//                             itemCount: latestQuizzes.length,
//                             itemBuilder: (context, index) {
//                               final quiz =
//                                   latestQuizzes[index].data()
//                                       as Map<String, dynamic>;
//
//                               return Padding(
//                                 padding: EdgeInsets.only(bottom: 16),
//                                 child: Row(
//                                   children: [
//                                     Container(
//                                       padding: EdgeInsets.all(16),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             padding: EdgeInsets.all(8),
//                                             decoration: BoxDecoration(
//                                               color: AppTheme.primaryColor
//                                                   .withOpacity(0.1),
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             child: Icon(
//                                               Icons.quiz_rounded,
//                                               color: AppTheme.primaryColor,
//                                               size: 20,
//                                             ),
//                                           ),
//                                           SizedBox(width: 16),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   quiz['title'],
//                                                   style: TextStyle(
//                                                     fontWeight: FontWeight.bold,
//                                                     color:
//                                                         AppTheme
//                                                             .textPrimaryColor,
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: 4),
//                                                 Text(
//                                                   'Created on ${_formatDate(quiz['createdAt'].toDate())}',
//                                                   style: TextStyle(
//                                                     fontSize: 12,
//                                                     color:
//                                                         AppTheme
//                                                             .textSecondaryColor,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24),
//                   Card(
//                     child: Padding(
//                       padding: EdgeInsets.all(20),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.speed_rounded,
//                                 color: AppTheme.primaryColor,
//                                 size: 24,
//                               ),
//                               SizedBox(width: 12),
//                               Text(
//                                 'Quiz Actions',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: AppTheme.textPrimaryColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 20),
//                           GridView.count(
//                             crossAxisCount: 2,
//                             shrinkWrap: true,
//                             mainAxisSpacing: 16,
//                             childAspectRatio: 0.9,
//                             crossAxisSpacing: 16,
//                             children: [
//                               _buildDashboardCard(
//                                 context,
//                                 'Quizzes',
//                                 Icons.quiz_rounded,
//                                 () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder:
//                                           (context) => ManageQuizesScreen(),
//                                     ),
//                                   );
//                                 },
//                               ),
//                               _buildDashboardCard(
//                                 context,
//                                 'Categories',
//                                 Icons.category_rounded,
//                                 () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder:
//                                           (context) => ManageCategoriesScreen(),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
