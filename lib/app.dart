import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'providers/user_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/theme_provider.dart';

class SafetifyAdminApp extends StatelessWidget {
  const SafetifyAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => IncidentProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const AdminAppView(),
    );
  }
}

class AdminAppView extends StatefulWidget {
  const AdminAppView({super.key});

  @override
  State<AdminAppView> createState() => _AdminAppViewState();
}

class _AdminAppViewState extends State<AdminAppView> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appRouter = AppRouter(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: _appRouter.router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
