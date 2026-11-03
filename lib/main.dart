import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/bindings/initial_binding.dart';
import 'app/constants/app_constants.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'core/database/app_database.dart';
import 'core/services/database_seeder.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 2. Initialize Drift SQLite Database
  final database = AppDatabase();

  // 3. Determine Initial Route
  final hasSession = prefs.getString(AppConstants.keyUserSession) != null;
  final initialRoute = hasSession ? AppRoutes.dashboard : AppRoutes.landing;

  // Mount UI immediately so screen never hangs on splash/background!
  runApp(
    KasirProApp(
      database: database,
      prefs: prefs,
      initialRoute: initialRoute,
    ),
  );

  // Non-blocking background initializations:
  Future.microtask(() async {
    try {
      await initializeDateFormatting('id_ID', null);
    } catch (_) {}

    try {
      final seeder = DatabaseSeeder(database);
      await seeder.seedIfEmpty().timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Background seeder note: $e');
    }

    try {
      await SupabaseService.initialize().timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Supabase init note: $e');
    }
  });
}

class KasirProApp extends StatelessWidget {
  final AppDatabase database;
  final SharedPreferences prefs;
  final String initialRoute;

  const KasirProApp({
    super.key,
    required this.database,
    required this.prefs,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(database: database, prefs: prefs),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      locale: const Locale('id', 'ID'),
    );
  }
}
