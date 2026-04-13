import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'theme/splash_screen.dart';
import 'services/connectivity_service.dart';
import 'services/sync_service.dart';
import 'services/history_service.dart';
import 'services/bookmark_service.dart';
import 'services/settings_service.dart';
import 'services/firestore_service.dart';

final darkModeNotifier = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  await FirestoreService.instance.init();
  await ConnectivityService().init();
  await SyncService().init();
  await HistoryService().init();
  await BookmarkService().init();
  await SettingsService().init();
  
  runApp(const BanualectoApp());
}

class BanualectoApp extends StatelessWidget {
  const BanualectoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HistoryService()),
        ChangeNotifierProvider(create: (_) => BookmarkService()),
        ChangeNotifierProvider(create: (_) => SyncService()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProvider(create: (_) => FirestoreService()),
      ],
      child: ValueListenableBuilder<bool>(
        valueListenable: darkModeNotifier,
        builder: (context, isDark, _) {
          return MaterialApp(
            title: 'Banualecto',
            debugShowCheckedModeBanner: false,
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.theme,
            darkTheme: AppTheme.darkTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}