import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/constants.dart';

class DashboardSidebar extends StatefulWidget {
  const DashboardSidebar({super.key});

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> {
  bool _isHovered = false;

  void _onEnter(PointerEvent details) {
    setState(() {
      _isHovered = true;
    });
  }

  void _onExit(PointerEvent details) {
    setState(() {
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = _isHovered ? 250.0 : 70.0;

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        color: theme.colorScheme.surface,
        child: Column(
          children: [
            // Header / Logo
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 80,
              padding: EdgeInsets.symmetric(horizontal: _isHovered ? 24.0 : 0),
              alignment: Alignment.center,
              child: _isHovered
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.security, color: theme.colorScheme.primary, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            AppConstants.appName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : Icon(Icons.security, color: theme.colorScheme.primary, size: 32),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildNavItem(context, 0, 'Overview', Icons.dashboard, '/dashboard'),
                  _buildNavItem(context, 1, 'Incidents', Icons.report_problem, '/incidents'),
                  _buildNavItem(context, 2, 'Users', Icons.people, '/users'),
                  _buildNavItem(context, 3, 'Alerts', Icons.notifications_active, '/alerts'),
                  _buildNavItem(context, 4, 'Map', Icons.map, '/map'),
                  _buildNavItem(context, 5, 'Analytics', Icons.analytics, '/analytics'),
                  _buildNavItem(context, 6, 'Settings', Icons.settings, '/settings'),
                  _buildNavItem(context, 7, 'Audit Logs', Icons.history, '/audit-logs'),
                  const Divider(),
                  _buildNavItem(context, 8, 'Profile', Icons.person, '/profile'),
                ],
              ),
            ),
            const Divider(),
            // Logout Button
            _buildLogoutItem(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, String title, IconData icon, String route) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final isSelected = dashboardProvider.selectedIndex == index;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        dashboardProvider.setIndex(index);
        context.go(route);
      },
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primaryContainer.withOpacity(0.2) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: _isHovered ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              child: Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (_isHovered)
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return InkWell(
      onTap: () => _showLogoutDialog(context, authProvider),
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: _isHovered ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              child: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
              ),
            ),
            if (_isHovered)
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              authProvider.signOut();
              context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
