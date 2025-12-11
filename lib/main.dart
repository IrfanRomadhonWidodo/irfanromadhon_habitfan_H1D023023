import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/local/habit_local_service.dart';
import 'ui/viewmodels/habit_viewmodel.dart';
import 'ui/pages/home_page.dart';
import 'utils/notification_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HabitLocalService.initialize();

  // Initialize notification service (skip on web)
  if (!kIsWeb) {
    await NotificationService().initialize();
  }

  runApp(const HabitFanApp());
}

class HabitFanApp extends StatelessWidget {
  const HabitFanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HabitViewModel(),
      child: MaterialApp(
        title: 'HabitFan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomePage(),
      ),
    );
  }
}
