import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/data_table_widget.dart';
import '../../utils/helpers.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final users = userProvider.users;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'User Management',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        CustomCard(
          child: userProvider.isLoading
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ))
              : DataTableWidget(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Joined')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: users.map((user) {
                    return DataRow(cells: [
                      DataCell(Text(user.name)),
                      DataCell(Text(user.email)),
                      DataCell(Text(user.role)),
                      DataCell(Text(Helpers.formatShortDate(user.createdAt))),
                      DataCell(
                        Text(
                          user.isBanned ? 'Banned' : 'Active',
                          style: TextStyle(
                            color: user.isBanned ? Colors.red : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                user.isBanned ? Icons.check_circle : Icons.block,
                                color: user.isBanned ? Colors.green : Colors.red,
                              ),
                              tooltip: user.isBanned ? 'Unban User' : 'Ban User',
                              onPressed: () {
                                final admin = Provider.of<AuthProvider>(context, listen: false).currentUser;
                                if (admin != null) {
                                  userProvider.toggleBanStatus(user.id, user.isBanned, admin.id, admin.name);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
