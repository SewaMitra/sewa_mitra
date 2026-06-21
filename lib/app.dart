import 'package:flutter/material.dart';
import 'core/router.dart';

class SewaMitraApp extends StatelessWidget {
  const SewaMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sewa Mitra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
