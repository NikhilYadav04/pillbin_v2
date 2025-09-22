import 'package:flutter/material.dart';
import 'package:pillbin/features/auth/presentation/pages/complete_profile_screen.dart';
import 'package:pillbin/features/auth/presentation/pages/otp_field_screen.dart';
import 'package:pillbin/features/auth/presentation/pages/phone_field_screen.dart';
import 'package:pillbin/features/campaign/presentation/pages/campaign_screen.dart';
import 'package:pillbin/features/chatbot/presentation/pages/chatbot_screen.dart';
import 'package:pillbin/features/home/presentation/pages/home_screen.dart';
import 'package:pillbin/features/landing_screen.dart';
import 'package:pillbin/features/locations/presentation/pages/location_screen.dart';
import 'package:pillbin/features/medicines/presentation/pages/add_medicine_screen.dart';
import 'package:pillbin/features/medicines/presentation/pages/medicine_inventory_screen.dart';
import 'package:pillbin/features/medicines/presentation/pages/medicines_screen.dart';
import 'package:pillbin/features/profile/presentation/pages/profile_screen.dart';
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
}) {
  return PageRouteBuilder(
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
      page = UserRegistrationForm();
      break;
    case '/home-screen':
      page = HomeScreen();
      break;
    case '/location-screen':
      page = LocationScreen();
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
    case '/profile-screen':
      page = ProfileScreen();
      break;
    case '/campaign-screen':
      page = MyCampaignsScreen();
      break;
    case '/chatbot-screen':
      page = ChatBotScreen();
      break;

    //* Error Handling
    default:
      page = Text("No Pages Available");
      break;
  }

  return buildPageRoute(
    page,
    type: type ?? TransitionType.rightToLeft,
    duration: duration ?? const Duration(milliseconds: 200),
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