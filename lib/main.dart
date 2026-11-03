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

  // Initialize Indonesian locale for Intl date formatting
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (e) {
    debugPrint('Locale format error: $e');
  }

  // 1. SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 2. Initialize Drift SQLite Database
  late final AppDatabase database;
  try {
    database = AppDatabase();
    // 3. Seed Demo Data if First Launch
    final seeder = DatabaseSeeder(database);
    await seeder.seedIfEmpty();
  } catch (e, stack) {
    debugPrint('Database init/seed error: $e\n$stack');
    database = AppDatabase();
  }

  // 4. Initialize Supabase (with offline fallback)
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Supabase init error: $e');
  }

  // 5. Determine Initial Route
  final hasSession = prefs.getString(AppConstants.keyUserSession) != null;
  final initialRoute = hasSession ? AppRoutes.dashboard : AppRoutes.landing;

  runApp(
    KasirProApp(
      database: database,
      prefs: prefs,
      initialRoute: initialRoute,
    ),
  );
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
