// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pillbin/features/chatbot/data/repository/chatbot_provider.dart';
// import 'package:pillbin/features/profile/data/repository/user_provider.dart';

// class TestScreenUser extends StatefulWidget {
//   const TestScreenUser({super.key});

//   @override
//   State<TestScreenUser> createState() => _TestScreenUserState();
// }

// class _TestScreenUserState extends State<TestScreenUser> {
//   //* provider
//   final UserProvider _userProvider = UserProvider();
//   final ChatbotProvider _chatbotProvider = ChatbotProvider();

//   // Test phone number for testing
//   final String testPhoneNumber = "+1234567890";

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(height: 20),

//             Center(
//               child: Text(
//                 "User Test",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             SizedBox(height: 30),

//             // 5. Complete Profile
//             _buildTestButton(
//               title: "Complete Profile",
//               color: Colors.teal,
//               onPressed: () {
//                 _userProvider.completeProfile(
//                   context: context,
//                   fullName: "John Doe",
//                   phone: "915202571",
//                   currentMedicines: [
//                     {"name": "Aspirin", "dosage": "100mg", "frequency": "Daily"}
//                   ],
//                   medicalConditions: [
//                     {"condition": "Hypertension", "severity": "Mild"}
//                   ],
//                   locationName: "New York City, USA",
//                   latitude: 40.7128, // Dummy lat
//                   longitude: -74.0060, // Dummy long
//                 );

//                 //  Logger().d(_userProvider.user?.fullName);
//               },
//             ),

//             SizedBox(height: 30),

//             // User Profile Section Header
//             Center(
//               child: Text(
//                 "User Profile Routes",
//                 style: TextStyle(
//                   color: Colors.black87,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             SizedBox(height: 20),

//             // 6. Edit Profile
//             _buildTestButton(
//                 title: "Edit Profile",
//                 color: Colors.indigo,
//                 onPressed: () {
//                   _userProvider.editProfile(
//                     context: context,
//                     fullName: "Nikkk",
//                     phone: "9152502571",
//                     currentMedicines: [
//                       {
//                         "name": "Aspirin",
//                         "dosage": "100mg",
//                         "frequency": "Daily"
//                       }
//                     ],
//                     medicalConditions: [
//                       {"condition": "Hypertension", "severity": "Mild"}
//                     ],
//                     locationName: "New York City, USA",
//                     latitude: 40.7128, // Dummy lat
//                     longitude: -74.0060, // Dummy long
//                   );
//                 }),

//             SizedBox(height: 15),

//             // 7. Get Profile
//             _buildTestButton(
//               title: "Get Profile",
//               color: Colors.cyan,
//               onPressed: () {
//                 _userProvider.getProfile(context: context);
//               },
//             ),

//             SizedBox(height: 15),

//             // 8. Save Medical Center
//             _buildTestButton(
//               title: "Save Medical Center",
//               color: Colors.red,
//               onPressed: () => _testSaveMedicalCenter(),
//             ),

//             SizedBox(height: 15),

//             // 9. Remove Saved Medical Center
//             _buildTestButton(
//               title: "Remove Saved Medical Center",
//               color: Colors.pink,
//               onPressed: () => _testRemoveSavedMedicalCenter(),
//             ),

//             SizedBox(height: 15),

//             // 10. Get Saved Medical Centers
//             _buildTestButton(
//               title: "Get Saved Medical Centers",
//               color: Colors.brown,
//               onPressed: () => _testGetSavedMedicalCenters(),
//             ),

//             SizedBox(height: 15),

//             // 10. Get Saved Medical Centers
//             _buildTestButton(
//               title: "Chatbot",
//               color: Colors.brown,
//               onPressed: () {
//                 _chatbotProvider.sendQueryToChatbot(
//                     context: context,
//                     prompt: "WHat would you prefer mango or apple?");
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTestButton({
//     required String title,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           padding: EdgeInsets.symmetric(vertical: 15),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   void _testCompleteProfile() async {
//     try {
//       print("Testing Complete Profile...");
//       // Replace with your actual method call
//       // await _authProvider.completeProfile(userProfileData);
//       _showMessage("Complete Profile - Test Called", Colors.teal);
//     } catch (e) {
//       _showMessage("Error: $e", Colors.red);
//     }
//   }

//   // User Profile Route Test Methods
//   void _testEditProfile() async {
//     try {
//       print("Testing Edit Profile...");
//       // Replace with your actual method call
//       // await _authProvider.editProfile(updatedProfileData);
//       _showMessage("Edit Profile - Test Called", Colors.indigo);
//     } catch (e) {
//       _showMessage("Error: $e", Colors.red);
//     }
//   }

//   void _testGetProfile() async {
//     try {
//       print("Testing Get Profile...");
//       // Replace with your actual method call
//       // var profile = await _authProvider.getProfile();
//       _showMessage("Get Profile - Test Called", Colors.cyan);
//     } catch (e) {
//       _showMessage("Error: $e", Colors.red);
//     }
//   }

//   void _testSaveMedicalCenter() async {
//     try {
//       print("Testing Save Medical Center...");
//       // Replace with your actual method call
//       // await _authProvider.saveMedicalCenter(medicalCenterId);
//       _showMessage("Save Medical Center - Test Called", Colors.red);
//     } catch (e) {
//       _showMessage("Error: $e", Colors.red);
//     }
//   }

//   void _testRemoveSavedMedicalCenter() async {
//     try {
//       print("Testing Remove Saved Medical Center...");
//       // Replace with your actual method call
//       // await _authProvider.removeSavedMedicalCenter(medicalCenterId);
//       _showMessage("Remove Saved Medical Center - Test Called", Colors.pink);
//     } catch (e) {
//       _showMessage("Error: $e", Colors.red);
//     }
//   }

//   void _testGetSavedMedicalCenters() async {
//     try {
//       print("Testing Get Saved Medical Centers...");
//       // Replace with your actual method call
//       // var savedCenters = await _authProvider.getSavedMedicalCenters();
//       _showMessage("Get Saved Medical Centers - Test Called", Colors.brown);
//     } catch (e) {
//       _showMessage("Error: $e", Colors.red);
//     }
//   }

//   void _showMessage(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }
// }
