import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/incident_provider.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Welcome back, ${user?.name ?? 'Admin'}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
                style: IconButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 8),
              Consumer<IncidentProvider>(
                builder: (context, incidentProvider, _) {
                  final pendingCount = incidentProvider.incidents
                      .where((i) => i.status == 'pending')
                      .length;
                  return Badge(
                    label: Text(pendingCount.toString()),
                    isLabelVisible: pendingCount > 0,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () => context.go('/incidents'),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              PopupMenuButton<String>(
                child: CircleAvatar(
                  backgroundImage: user?.profileImage != null
                      ? NetworkImage(user!.profileImage!)
                      : null,
                  child: user?.profileImage == null
                      ? Text(user?.name.substring(0, 1).toUpperCase() ?? 'A')
                      : null,
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    authProvider.signOut();
                    context.go('/login');
                  } else if (value == 'profile') {
                    context.go('/profile');
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Text('Profile'),

                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
