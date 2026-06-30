import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/router.dart';
import 'viewmodels/wallet_viewmodel.dart';
import 'viewmodels/provider_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'viewmodels/user_viewmodel.dart';

class SewaMitraApp extends StatelessWidget {
  const SewaMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletViewModel()),
        ChangeNotifierProvider(create: (_) => ProviderViewModel()),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()..init()),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void initState() {
    super.initState();
    // Load saved dark mode preference after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeViewModel>().loadFromFirestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();

    return MaterialApp.router(
      title: 'Sewa Mitra',
      debugShowCheckedModeBanner: false,
      themeMode: themeVM.themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      routerConfig: AppRouter.router,
    );
  }
}

ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFF97316),
      primary: const Color(0xFFF97316),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F9FA),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A2E),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
    ),
    cardColor: Colors.white,
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? const Color(0xFFF97316) : null),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? const Color(0xFFF97316).withValues(alpha: 0.4) : null),
    ),
  );
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFF97316),
      primary: const Color(0xFFF97316),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: const Color(0xFF1E1E1E),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? const Color(0xFFF97316) : null),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? const Color(0xFFF97316).withValues(alpha: 0.4) : null),
    ),
  );
}
