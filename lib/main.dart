import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/quest_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Deep dark status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgDeep,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SoloLevelingApp());
}

class SoloLevelingApp extends StatelessWidget {
  const SoloLevelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestProvider()..init()),
      ],
      child: MaterialApp(
        title: 'Solo System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AppLoader(),
      ),
    );
  }
}

class AppLoader extends StatefulWidget {
  const AppLoader({super.key});

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    // Show splash for min 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestProvider>();

    if (!_splashDone || provider.isLoading) {
      return const SplashScreen();
    }

    return const MainShell();
  }
}
