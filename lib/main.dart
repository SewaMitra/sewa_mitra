import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'features/home/home_screen.dart';
import 'firebase_options.dart';
import 'viewmodels/wallet_viewmodel.dart';
import 'viewmodels/provider_viewmodel.dart';
import 'main_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletViewModel()),
        ChangeNotifierProvider(create: (_) => ProviderViewModel()),
        // Add other viewmodels as needed
      ],
      child: MaterialApp(
        title: 'Sewa Mitra',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
          ),
        ),
        home: const MainContainer(child: HomeScreen()),
        // Add routes here
      ),
    );
  }
}