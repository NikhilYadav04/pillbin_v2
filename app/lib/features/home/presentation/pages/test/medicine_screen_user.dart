// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:pillbin/features/medicines/data/repository/medicine_provider.dart';

// class TestScreenMedicine extends StatefulWidget {
//   const TestScreenMedicine({super.key});

//   @override
//   State<TestScreenMedicine> createState() => _TestScreenMedicineState();
// }

// class _TestScreenMedicineState extends State<TestScreenMedicine> {
//   //* provider
//   final MedicineProvider _medicineProvider = MedicineProvider();

//   // Test medicine ID for testing
//   final String testMedicineId = "med_123456";

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
//                 "Medicine Test Routes",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),

//             SizedBox(height: 30),

//             // 1. Get Medicine
//             _buildTestButton(
//               title: "Add Medicine",
//               color: Colors.blue,
//               onPressed: () {
//                 _medicineProvider.addMedicine(
//                   context: context,
//                   name: "Amoxicillin",
//                   expiryDate: DateTime.now()
//                       .subtract(Duration(days: 60))
//                       .toIso8601String(),
//                   notes: "Antibiotic (expired)",
//                   dosage: "1 capsule/8 hours",
//                   manufacturer: "HealthPharma",
//                   batchNumber: "EXP002",
//                 );
//               },
//             ),

//             SizedBox(height: 15),

//             // 2. Get Inventory
//             _buildTestButton(
//               title: "Get Inventory",
//               color: Colors.green,
//               onPressed: () {
//                 _medicineProvider.getInventory(context: context);
//               },
//             ),

//             SizedBox(height: 15),

//             // 3. Update Medicine
//             _buildTestButton(
//                 title: "Update Medicine",
//                 color: Colors.orange,
//                 onPressed: () {
//                   _medicineProvider.updateMedicine(
//                     context: context,
//                     medicineId: "68d0d4fd891208c21efc723c",
//                     name: "Cetirizine",
//                     expiryDate: DateTime.now()
//                         .add(Duration(days: 250))
//                         .toIso8601String(),
//                     notes: "Anti-allergy",
//                     dosage: "1 tablet/night",
//                     manufacturer: "CareWell Inc.",
//                     batchNumber: "BATCH003",
//                   );
//                 }),

//             SizedBox(height: 15),

//             // 4. Delete Medicine
//             _buildTestButton(
//               title: "Delete Medicine",
//               color: Colors.red,
//               onPressed: () {
//                 _medicineProvider.deleteMedicine(
//                     context: context, medicineId: "68d0d6c0b3d465895e3f3aa7");
//               },
//             ),

//             SizedBox(height: 15),

//             // 5. Delete All Expired Medicine
//             _buildTestButton(
//               title: "Delete All Expired Medicine",
//               color: Colors.purple,
//               onPressed: () => {
//                 _medicineProvider.deleteAllExpiredMedicines(context: context)
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

//   // Medicine Test method implementations
//   void _testGetMedicine() async {
//     try {
//       print("Testing Get Medicine...");
//       // Replace with your actual method call
//       // var medicine = await _authProvider.getMedicine(testMedicineId);
//       _showMessage("Get Medicine - Test Called", Colors.blue);
//     } catch (e) {
//       _showMessage("Error: $e", Colors.red);
//     }
//   }

//   void _testGetInventory() async {
//     try {
//       print("Testing Get Inventory...");
//       // Replace with your actual method call
//       // var inventory = await _authProvider.getInventory();
//       _showMessage("Get Inventory - Test Called", Colors.green);
//     } catch (e) {
//       _showMessage("Error: $e", Colors.red);
//     }
//   }

//   void _testUpdateMedicine() async {
//     try {
//       print("Testing Update Medicine...");
//       // Replace with your actual method call
//       // await _authProvider.updateMedicine(testMedicineId, updatedMedicineData);
//       _showMessage("Update Medicine - Test Called", Colors.orange);
//     } catch (e) {
//       _showMessage("Error: $e", Colors.red);
//     }
//   }

//   void _testDeleteMedicine() async {
//     try {
//       print("Testing Delete Medicine...");
//       // Replace with your actual method call
//       // await _authProvider.deleteMedicine(testMedicineId);
//       _showMessage("Delete Medicine - Test Called", Colors.red);
//     } catch (e) {
//       _showMessage("Error: $e", Colors.red);
//     }
//   }

//   void _testDeleteAllExpiredMedicine() async {
//     try {
//       print("Testing Delete All Expired Medicine...");
//       // Replace with your actual method call
//       // await _authProvider.deleteAllExpiredMedicine();
//       _showMessage("Delete All Expired Medicine - Test Called", Colors.purple);
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
