import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/core/constants/dummy.dart';
import 'package:pillbin/features/auth/data/repository/auth_provider.dart';
import 'package:pillbin/features/chatbot/data/repository/chatbot_provider.dart';
import 'package:pillbin/features/health_ai/data/repository/health_ai_provider.dart';
import 'package:pillbin/features/health_ai/data/repository/rag_provider.dart';
import 'package:pillbin/features/home/data/repository/notification_provider.dart';
import 'package:pillbin/features/locations/data/repository/medical_center_provider.dart';
import 'package:pillbin/features/medicines/data/repository/medicine_provider.dart';
import 'package:pillbin/features/profile/data/repository/user_provider.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Dummy()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => MedicalCenterProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => HealthAiProvider()),
        ChangeNotifierProvider(create: (_) => RagProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navKey,
        debugShowCheckedModeBanner: false,
        title: 'PillBin',
        initialRoute: '/',
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
