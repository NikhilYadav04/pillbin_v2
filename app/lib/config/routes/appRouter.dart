import 'package:flutter/material.dart';
import 'package:pillbin/features/auth/presentation/pages/complete_profile_screen.dart';
import 'package:pillbin/features/auth/presentation/pages/otp_field_screen.dart';
import 'package:pillbin/features/auth/presentation/pages/phone_field_screen.dart';
import 'package:pillbin/features/blog/presentation/pages/add_blog_post_screen.dart';
import 'package:pillbin/features/blog/presentation/pages/all_blogs_screen.dart';
import 'package:pillbin/features/blog/presentation/pages/my_blogs_screen.dart';
import 'package:pillbin/features/blog/presentation/pages/update_blog_screen.dart';
import 'package:pillbin/features/campaign/presentation/pages/campaign_screen.dart';
import 'package:pillbin/features/depreceated/chatbot/presentation/pages/chatbot_screen.dart';
import 'package:pillbin/features/depreceated/health_ai/presentation/pages/health_ai_history_screen.dart';
import 'package:pillbin/features/home/presentation/pages/home_screen.dart';
import 'package:pillbin/features/home/presentation/pages/notification_screen.dart';
import 'package:pillbin/features/info/presentation/pages/info_page.dart';
import 'package:pillbin/features/landing_screen.dart';
import 'package:pillbin/features/locations/presentation/pages/location_screen.dart';
import 'package:pillbin/features/locations/presentation/pages/medical_centers_view_all_screen.dart';
import 'package:pillbin/features/locations/presentation/pages/saved_medical_centers_view.dart';
import 'package:pillbin/features/locations/presentation/widgets/location_detail_card.dart';
import 'package:pillbin/features/medicines/presentation/pages/add_medicine_screen.dart';
import 'package:pillbin/features/medicines/presentation/pages/edit_medicine_screen.dart';
import 'package:pillbin/features/medicines/presentation/pages/medicine_history_screen.dart';
import 'package:pillbin/features/medicines/presentation/pages/medicine_inventory_screen.dart';
import 'package:pillbin/features/medicines/presentation/pages/medicines_screen.dart';
import 'package:pillbin/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:pillbin/features/profile/presentation/pages/impact_screen.dart';
import 'package:pillbin/features/profile/presentation/pages/profile_screen.dart';
import 'package:pillbin/features/donation/presentation/pages/center_reviews_screen.dart';
import 'package:pillbin/features/donation/presentation/pages/donation_qr_screen.dart';
import 'package:pillbin/features/donation/presentation/pages/donation_receipt_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_scan_screen.dart';
import 'package:pillbin/features/donation/presentation/pages/donation_request_screen.dart';
import 'package:pillbin/features/donation/presentation/pages/my_donations_screen.dart';
import 'package:pillbin/features/splash_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_analytics_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_bottom_bar_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_claim_center_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_dashboard_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_donated_medicines_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_inventory_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_reviews_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_onboarding_screen.dart';
import 'package:pillbin/features/vendor/presentation/pages/vendor_requests_screen.dart';
import 'package:pillbin/network/models/blog_model.dart';
import 'package:pillbin/network/models/medical_center_model.dart';
import 'package:pillbin/root_screen.dart';

enum TransitionType {
  rightToLeft,
  leftToRight,
  bottomToTop,
  topToBottom,
  fade,
}

///* Builds a PageRoute with the given [child], using [type] and [duration].
PageRouteBuilder<dynamic> buildPageRoute(
  Widget child, {
  TransitionType type = TransitionType.rightToLeft,
  Duration duration = const Duration(milliseconds: 200),
  RouteSettings? settings,
}) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (_, __, ___) => child,
    transitionDuration: duration,
    transitionsBuilder: (_, animation, __, child) {
      final curveAnim = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );

      switch (type) {
        case TransitionType.leftToRight:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1, 0),
              end: Offset.zero,
            ).animate(curveAnim),
            child: child,
          );
        case TransitionType.topToBottom:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1),
              end: Offset.zero,
            ).animate(curveAnim),
            child: child,
          );
        case TransitionType.bottomToTop:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curveAnim),
            child: child,
          );
        case TransitionType.fade:
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        case TransitionType.rightToLeft:
        default:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(curveAnim),
            child: child,
          );
      }
    },
  );
}

/// Centralized route generator that reads transition type & duration
Route<dynamic> generateRoute(RouteSettings settings) {
  final args = settings.arguments as Map<String, dynamic>?;
  final type = args?['transition'] as TransitionType?;
  final ms = args?['duration'] as int?;
  final duration = ms != null ? Duration(milliseconds: ms) : null;

  Widget page;
  switch (settings.name) {
    case '/':
      page = SplashScreen();
      break;
    case '/landing-screen':
      page = LandingPage();
      break;
    case '/phone-field-screen':
      bool isLogin = args?['login'] ?? false;
      page = EmailAuthScreen(isLogin: isLogin);
      break;
    case '/bottom-bar-screen':
      page = BottomBarScreen();
      break;
    case '/otp-field-screen':
      String email = args?['email'] ?? "";
      bool isLogin = args?['login'] ?? false;
      page = OtpScreen(email: email, isLogin: isLogin);
      break;
    case '/complete-profile-screen':
      String phone = args?['phone'] ?? "";
      page = UserRegistrationForm(
        phone: phone,
      );
      break;
    case '/edit-medicine-screen':
      final String medicineId = args?['medicineId'] ?? '';
      final String medicineName = args?['medicineName'] ?? '';
      final String medicineType = args?['medicineType'] ?? '';
      final DateTime expiryDate = args?['expiryDate'] ?? DateTime.now();
      final DateTime purchaseDate = args?['purchaseDate'] ?? DateTime.now();
      final String quantity = args?['quantity'] ?? "0";
      final String manufacturer = args?['manufacturer'] ?? '';
      final String batchNumber = args?['batchNumber'] ?? '';
      final String notes = args?['notes'] ?? '';

      page = EditMedicineScreen(
        medicineId: medicineId,
        medicineName: medicineName,
        medicineType: medicineType,
        expiryDate: expiryDate,
        purchaseDate: purchaseDate,
        quantity: quantity,
        manufacturer: manufacturer,
        batchNumber: batchNumber,
        notes: notes,
      );
      break;

    case '/edit-profile-screen':
      String fullName = args?['fullName'] ?? "";
      String phone = args?["phone"] ?? "";
      String locationName = args?["locationName"] ?? "";
      double latitude = args?["latitude"] ?? 0.0;
      double longitude = args?["longitude"] ?? 0.0;
      List<Map<String, dynamic>> currentMedicines =
          args?["currentMedicines"] ?? [];
      List<Map<String, dynamic>> medicalConditions =
          args?["medicalConditions"] ?? [];

      page = ProfileEditScreen(
          fullName: fullName,
          phone: phone,
          locationName: locationName,
          latitude: latitude,
          longitude: longitude,
          currentMedicines: currentMedicines,
          medicalConditions: medicalConditions);
      break;
    case '/home-screen':
      page = HomeScreen();
      break;
    case '/location-screen':
      page = LocationScreen();
      break;
    case '/location-card-display':
      MedicalCenter center = args?['center'];
      double sw = args?['sw'] ?? 0.0;
      double sh = args?['sh'] ?? 0.0;
      page = MedicalCenterDetailScreen(center: center, sw: sw, sh: sh);
      break;
    case '/medical-center-display-detail':
      page = MedicalCentersViewAllScreen();
      break;
    case '/medical-center-display-saved':
      page = SavedMedicalCentersScreen();
      break;
    case '/medicine-screen':
      page = InventoryScreen();
      break;
    case '/add-medicine-screen':
      page = AddMedicineScreen();
      break;
    case '/inventory-screen':
      page = MyInventoryScreen();
      break;
    case '/medicine-history-screen':
      page = MedicineHistoryScreen();
      break;
    case '/profile-screen':
      page = ProfileScreen();
      break;
    case '/impact-screen':
      page = const ImpactScreen();
      break;
    case '/notification-screen':
      page = ViewAllNotificationsScreen();
      break;
    case '/campaign-screen':
      page = MyCampaignsScreen();
      break;
    case '/chatbot-screen':
      page = ChatBotScreen();
      break;
    case '/info-screen':
      page = InformationHubBaseScreen();
      break;
    case '/rag-history-screen':
      page = RagHistoryScreen();
      break;

    //* Blog
    case '/add-blog-post-screen':
      page = AddBlogPostScreen();
      break;
    case '/my-blog-post-screen':
      page = MyBlogsScreen();
      break;
    case '/all-blog-posts-screen':
      page = AllBlogsScreen();
      break;
    case '/update-blog-post-screen':
      BlogModel blog = args?['blog'] ?? "";
      page = UpdateBlogPostScreen(
        blog: blog,
      );
      break;

    //* Vendor routes
    case '/vendor-onboarding-screen':
      page = VendorOnboardingScreen(
          startAtStep: (args?['startAtStep'] as int?) ?? 0);
      break;
    case '/vendor-claim-center-screen':
      page = const VendorClaimCenterScreen();
      break;
    case '/vendor-dashboard-screen':
      page = const VendorDashboardScreen();
      break;
    case '/vendor-bottom-bar-screen':
      page = const VendorBottomBarScreen();
      break;
    case '/vendor-reviews-screen':
      page = const VendorReviewsScreen();
      break;
    case '/vendor-analytics-screen':
      page = const VendorAnalyticsScreen();
      break;
    case '/vendor-donated-medicines-screen':
      page = const VendorDonatedMedicinesScreen();
      break;
    case '/vendor-inventory-screen':
      page = const VendorInventoryScreen();
      break;
    case '/vendor-requests-screen':
      page = const VendorRequestsScreen();
      break;

    //* Donation routes
    case '/donation-request-screen':
      final centerId = args?['centerId'] as String? ?? '';
      final centerName = args?['centerName'] as String? ?? '';
      page = DonationRequestScreen(centerId: centerId, centerName: centerName);
      break;
    case '/my-donations-screen':
      page = const MyDonationsScreen();
      break;
    case '/donation-qr-screen':
      page = DonationQrScreen(
        requestId: args?['requestId'] as String? ?? '',
        centerName: args?['centerName'] as String? ?? 'the center',
      );
      break;
    case '/vendor-scan-screen':
      page = const VendorScanScreen();
      break;
    case '/donation-receipt-screen':
      page = DonationReceiptScreen(
        data: args?['data'] as DonationReceiptData,
      );
      break;
    case '/center-reviews-screen':
      page = CenterReviewsScreen(
        centerId: args?['centerId'] as String? ?? '',
        centerName: args?['centerName'] as String? ?? 'Medical Center',
      );
      break;

    //* Error Handling
    default:
      page = const Text("No Pages Available");
      break;
  }

  return buildPageRoute(
    page,
    type: type ?? TransitionType.rightToLeft,
    duration: duration ?? const Duration(milliseconds: 200),
    settings: settings,
  );
}

// Example of pushing with custom transition & duration:
// Navigator.pushNamed(
//   context,
//   '/sign-in',
//   arguments: {
//     'transition': TransitionType.fade,
//     'duration': 300,
//   },
// );
