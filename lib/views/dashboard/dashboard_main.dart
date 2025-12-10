import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import 'dashboard_sidebar.dart';
import 'dashboard_header.dart';

class DashboardMain extends StatelessWidget {
  final Widget child;

  const DashboardMain({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const DashboardSidebar(),
          Expanded(
            child: Column(
              children: [
                const DashboardHeader(),
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    padding: const EdgeInsets.all(24),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
