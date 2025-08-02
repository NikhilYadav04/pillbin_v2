import 'package:flutter/material.dart';
import 'package:pillbin/config/routes/appRouter.dart';
import 'package:pillbin/core/constants/dummy.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Dummy()),
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
