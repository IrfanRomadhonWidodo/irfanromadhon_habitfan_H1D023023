import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/local/habit_local_service.dart';
import 'ui/viewmodels/habit_viewmodel.dart';
import 'ui/viewmodels/settings_viewmodel.dart';
import 'ui/pages/main_scaffold.dart';
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HabitViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: 'HabitFan',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainScaffold(),
          );
        },
      ),
    );
  }
}
