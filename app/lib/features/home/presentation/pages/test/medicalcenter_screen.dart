import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/features/locations/data/repository/medical_center_provider.dart';

class TestScreenMedicalCenter extends StatefulWidget {
  const TestScreenMedicalCenter({super.key});

  @override
  State<TestScreenMedicalCenter> createState() =>
      _TestScreenMedicalCenterState();
}

class _TestScreenMedicalCenterState extends State<TestScreenMedicalCenter> {
  //* provider
  final MedicalCenterProvider _medicalCenterProvider = MedicalCenterProvider();

  // Test data for testing
  final String testMedicalCenterId = "mc_123456";
  final String testSearchQuery = "hospital";
  final double testLatitude = 22.5726;
  final double testLongitude = 88.3639; // Kolkata coordinates

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            Center(
              child: Text(
                "Medical Center Test Routes",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            SizedBox(height: 30),

            // 1. Add Medical Center
            _buildTestButton(
                title: "Add Medical Center",
                color: Colors.blue,
                onPressed: () {
                  _medicalCenterProvider.addMedicalCenter(
                    context: context,
                    name: "Green Valley Clinic",
                    address: "321 Green Lane, Mumbai, MH 400004",
                    phoneNumber: "+91-98765-44444",
                    latitude: 19.200000, // ~4 km west of reference
                    longitude: 72.930000,
                    acceptedMedicineTypes: ["tablets", "syrups", "capsules"],
                    operatingHours: {
                      "monday": {"open": "08:30", "close": "18:30"},
                      "tuesday": {"open": "08:30", "close": "18:30"},
                      "wednesday": {"open": "08:30", "close": "18:30"},
                      "thursday": {"open": "08:30", "close": "18:30"},
                      "friday": {"open": "08:30", "close": "18:30"},
                      "saturday": {"open": "09:00", "close": "16:00"},
                      "sunday": {"open": "10:00", "close": "14:00"}
                    },
                    facilityType: "clinic",
                    website: "https://greenvalleyclinic.com",
                    email: "contact@greenvalleyclinic.com",
                    specialServices: [
                      "Consultation",
                      "Health Checkups",
                      "Vaccination"
                    ],
                  );
                }),

            SizedBox(height: 15),

            // 2. Update Medical Center
            _buildTestButton(
              title: "Update Medical Center",
              color: Colors.green,
              onPressed: () {
                _medicalCenterProvider.addMedicalCenter(
                  context: context,
                  name: "Green Valley Clinic",
                  address: "321 Green Lane, Mumbai, MH 400004",
                  phoneNumber: "+91-98765-44444",
                  latitude: 19.200000, // ~4 km west of reference
                  longitude: 72.930000,
                  acceptedMedicineTypes: ["tablets", "syrups", "capsules"],
                  operatingHours: {
                    "monday": {"open": "08:30", "close": "18:30"},
                    "tuesday": {"open": "08:30", "close": "18:30"},
                    "wednesday": {"open": "08:30", "close": "18:30"},
                    "thursday": {"open": "08:30", "close": "18:30"},
                    "friday": {"open": "08:30", "close": "18:30"},
                    "saturday": {"open": "09:00", "close": "16:00"},
                    "sunday": {"open": "10:00", "close": "14:00"}
                  },
                  facilityType: "clinic",
                  website: "https://greenvalleyclinic.com",
                  email: "contact@greenvalleyclinic.com",
                  specialServices: [
                    "Consultation",
                    "Health Checkups",
                    "Vaccination"
                  ],
                );
              },
            ),

            SizedBox(height: 15),

            // 3. Delete Medical Center
            _buildTestButton(
              title: "Delete Medical Center",
              color: Colors.red,
              onPressed: () {
                _medicalCenterProvider.deleteMedicalCenter(
                    context: context,
                    medicalCenterId: "68d0db6b822e7d0c1588f16d");
              },
            ),

            SizedBox(height: 15),

            // 4. Get All Medical Centers
            _buildTestButton(
              title: "Get All Medical Centers",
              color: Colors.orange,
              onPressed: () {
                _medicalCenterProvider.getAllMedicalCenters(context: context);
              },
            ),

            SizedBox(height: 15),

            // 5. Get Nearby Medical Centers
            _buildTestButton(
              title: "Get Nearby Medical Centers",
              color: Colors.purple,
              onPressed: () {
                _medicalCenterProvider.resetPageFetch();
                _medicalCenterProvider.getNearbyMedicalCenters(
                    context: context,
                    latitude: 19.200000,
                    longitude: 72.970000,
                    radius: 4);
              },
            ),

            SizedBox(height: 15),

            // 6. Search Medical Centers
            _buildTestButton(
              title: "Search Medical Centers",
              color: Colors.teal,
              onPressed: () {
                _medicalCenterProvider.resetPageFetch();
                _medicalCenterProvider.searchMedicalCenters(
                    context: context, query: "een", facilityType: "");
              },
            ),

            SizedBox(height: 15),

            // 7. Get Medical Center by ID
            _buildTestButton(
              title: "Get Medical Center by ID",
              color: Colors.indigo,
              onPressed: () {
                _medicalCenterProvider.getMedicalCenterbyId(
                    context: context,
                    medicalCenterId: '68d11e002f0d1bf781e80e72');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton({
    required String title,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Medical Center Test method implementations
  void _testAddMedicalCenter() async {
    try {
      print("Testing Add Medical Center...");
      // Replace with your actual method call
      // await _authProvider.addMedicalCenter(medicalCenterData);
      _showMessage("Add Medical Center - Test Called", Colors.blue);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _testUpdateMedicalCenter() async {
    try {
      print("Testing Update Medical Center...");
      // Replace with your actual method call
      // await _authProvider.updateMedicalCenter(testMedicalCenterId, updatedData);
      _showMessage("Update Medical Center - Test Called", Colors.green);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _testDeleteMedicalCenter() async {
    try {
      print("Testing Delete Medical Center...");
      // Replace with your actual method call
      // await _authProvider.deleteMedicalCenter(testMedicalCenterId);
      _showMessage("Delete Medical Center - Test Called", Colors.red);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _testGetAllMedicalCenters() async {
    try {
      print("Testing Get All Medical Centers...");
      // Replace with your actual method call
      // var medicalCenters = await _authProvider.getAllMedicalCenters();
      _showMessage("Get All Medical Centers - Test Called", Colors.orange);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _testGetNearbyMedicalCenters() async {
    try {
      print("Testing Get Nearby Medical Centers...");
      print("Using coordinates: Lat: $testLatitude, Lng: $testLongitude");
      // Replace with your actual method call
      // var nearbyMedicalCenters = await _authProvider.getNearbyMedicalCenters(testLatitude, testLongitude, radius);
      _showMessage("Get Nearby Medical Centers - Test Called", Colors.purple);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _testSearchMedicalCenters() async {
    try {
      print("Testing Search Medical Centers...");
      print("Using search query: $testSearchQuery");
      // Replace with your actual method call
      // var searchResults = await _authProvider.searchMedicalCenters(testSearchQuery);
      _showMessage("Search Medical Centers - Test Called", Colors.teal);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _testGetMedicalCenterById() async {
    try {
      print("Testing Get Medical Center by ID...");
      print("Using Medical Center ID: $testMedicalCenterId");
      // Replace with your actual method call
      // var medicalCenter = await _authProvider.getMedicalCenterById(testMedicalCenterId);
      _showMessage("Get Medical Center by ID - Test Called", Colors.indigo);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
