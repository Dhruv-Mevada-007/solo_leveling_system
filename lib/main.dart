import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/quest_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/reminder_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'widgets/common/common_widgets.dart';

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
        ChangeNotifierProvider(create: (_) => QuestProvider()),
        ChangeNotifierProxyProvider<QuestProvider, HabitProvider>(
          create: (ctx) => HabitProvider(ctx.read<QuestProvider>()),
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
  bool _initDone = false;
  PenaltyEscalationResult? _escalationResult;

  @override
  void initState() {
    super.initState();
    _runInit();
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  Future<void> _runInit() async {
    final questProvider = context.read<QuestProvider>();
    final habitProvider = context.read<HabitProvider>();

    // Init sequentially so HabitProvider can safely call QuestProvider.addQuest
    final result = await questProvider.init();
    await habitProvider.init();

    if (mounted) {
      setState(() {
        _escalationResult = result;
        _initDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _splashDone && _initDone;

    if (!ready) return const SplashScreen();

    // Show escalation warning once after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final result = _escalationResult;
      if (result != null && result.hadEscalations) {
        _escalationResult = null; // clear so it only shows once
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => _SystemWarningDialog(result: result),
        );
      }
    });

    return const MainShell();
  }
}

class _SystemWarningDialog extends StatelessWidget {
  final PenaltyEscalationResult result;
  const _SystemWarningDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.danger, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withAlpha(60),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing warning icon
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.danger.withAlpha(25),
                border: Border.all(color: AppColors.danger, width: 2),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: AppColors.danger, size: 36),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  duration: 900.ms,
                  begin: const Offset(0.94, 0.94),
                  end: const Offset(1.06, 1.06),
                ),

            const SizedBox(height: 18),

            Text('[ SYSTEM ALERT ]',
                style: AppTextStyles.systemLabel
                    .copyWith(color: AppColors.danger)),

            const SizedBox(height: 8),

            Text(
              'Penalties Escalated',
              style: AppTextStyles.heading1
                  .copyWith(color: AppColors.danger, fontSize: 22),
            ),

            const SizedBox(height: 12),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: 'Escalated',
                    value: '${result.escalatedCount}',
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    label: 'XP Lost',
                    value: '-${result.totalXpLost}',
                    icon: Icons.remove_circle_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(
              'You ignored penalty task${result.escalatedCount > 1 ? 's' : ''}. '
              'The system has escalated them with shorter deadlines and higher stakes. '
              'Do not ignore them again.',
              style: AppTextStyles.body
                  .copyWith(fontSize: 13, height: 1.6),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.danger.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.danger, width: 1),
                ),
                child: Text(
                  'ACKNOWLEDGED',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.xpLabel.copyWith(
                      color: AppColors.danger,
                      fontSize: 13,
                      letterSpacing: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatChip(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.danger.withAlpha(60)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.danger, size: 16),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger)),
          Text(label,
              style: AppTextStyles.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}
