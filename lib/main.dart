import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/quest_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/reminder_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        ChangeNotifierProxyProvider<QuestProvider, HabitProvider>(
          create: (ctx) => HabitProvider(ctx.read<QuestProvider>())..init(),
          update: (_, quest, habit) => habit!,
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => ReminderProvider()..init()),
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
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final questProvider = context.watch<QuestProvider>();
    if (!_splashDone || questProvider.isLoading) {
      return const SplashScreen();
    }
    return const MainShell();
  }
}
