import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/audit_log_model.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/data_table_widget.dart';
import '../../utils/helpers.dart';

class AuditLogsPage extends StatelessWidget {
  const AuditLogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Audit Logs',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          CustomCard(
            child: StreamBuilder<List<AuditLogModel>>(
              stream: dashboardProvider.auditLogs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ));
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final logs = snapshot.data ?? [];

                if (logs.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No audit logs found.'),
                  ));
                }

                return DataTableWidget(
                  columns: const [
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('Admin')),
                    DataColumn(label: Text('Action')),
                    DataColumn(label: Text('Details')),
                  ],
                  rows: logs.map((log) {
                    return DataRow(cells: [
                      DataCell(Text(Helpers.formatDateTime(log.timestamp))),
                      DataCell(Text(log.adminName)),
                      DataCell(Text(log.action)),
                      DataCell(Text(log.details)),
                    ]);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
