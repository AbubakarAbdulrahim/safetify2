import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/incident_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/data_table_widget.dart';
import '../../widgets/status_badge.dart';
import '../../utils/helpers.dart';

class IncidentsPage extends StatefulWidget {
  const IncidentsPage({super.key});

  @override
  State<IncidentsPage> createState() => _IncidentsPageState();
}

class _IncidentsPageState extends State<IncidentsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final incidentProvider = Provider.of<IncidentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final admin = authProvider.currentUser;

    // 1. Filter by Status (Provider does this)
    var displaysList = incidentProvider.incidents;

    // 2. Filter by Search Query (Local)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      displaysList = displaysList.where((i) {
        return i.title.toLowerCase().contains(query) ||
            i.locationName.toLowerCase().contains(query) ||
            i.category.toLowerCase().contains(query);
      }).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Incident Command',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton.icon(
              onPressed: () {
                incidentProvider.refreshIncidents();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Refreshing data...')),
                );
              },
              icon: const Icon(Icons.refresh),
               label: const Text('Refresh Data'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        Expanded(
          child: CustomCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Toolbar: Search & Filters ---
                LayoutBuilder(builder: (context, constraints) {
                   return Wrap(
                     spacing: 16,
                     runSpacing: 16,
                     crossAxisAlignment: WrapCrossAlignment.center,
                     children: [
                       ConstrainedBox(
                         constraints: const BoxConstraints(maxWidth: 400),
                         child: TextField(
                           controller: _searchController,
                           decoration: InputDecoration(
                             prefixIcon: const Icon(Icons.search),
                             hintText: 'Search...',
                             border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(12),
                               borderSide: BorderSide.none,
                             ),
                             filled: true,
                             fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                           ),
                           onChanged: (value) => setState(() => _searchQuery = value),
                         ),
                       ),
                       _buildStatusFilterTabs(context, incidentProvider),
                     ],
                   );
                }),
                const SizedBox(height: 24),
    
                // --- Data Table ---
                Expanded(
                  child: incidentProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : displaysList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text('No incidents found matching your criteria', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: DataTableWidget(
                            columns: const [
                              DataColumn(label: Text('Evidence')),
                              DataColumn(label: Text('Incident Details')),
                              DataColumn(label: Text('Location')),
                              DataColumn(label: Text('Reported')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: displaysList.map((incident) {
                              return DataRow(
                                cells: [
                                  // Evidence (Image)
                                  DataCell(
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.grey[200],
                                        image: incident.photoUrl.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(incident.photoUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: incident.photoUrl.isEmpty
                                          ? const Icon(Icons.image_not_supported, size: 16, color: Colors.grey)
                                          : null,
                                    ),
                                  ),
                                  // Incident Details
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(incident.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(incident.category, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Location
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.place, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Flexible(child: Text(incident.locationName, overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                  ),
                                  // Date
                                  DataCell(Text(Helpers.formatShortDate(incident.timestamp))),
                                  // Status
                                  DataCell(StatusBadge(status: incident.status)),
                                  // Actions
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility_outlined),
                                          tooltip: 'View Details',
                                          onPressed: () => context.go('/incidents/${incident.id}'),
                                        ),
                                        if (incident.status == 'pending') ...[
                                          IconButton(
                                            icon: const Icon(Icons.check_circle_outline),
                                            color: Colors.green,
                                            tooltip: 'Quick Verify',
                                            onPressed: () {
                                               if (admin != null) {
                                                 incidentProvider.updateStatus(incident.id, 'verified', admin.id, admin.name);
                                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as Verified')));
                                               }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.cancel_outlined),
                                            color: Colors.red,
                                            tooltip: 'Reject',
                                            onPressed: () async {
                                              if (admin != null) {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Reject & Delete Incident'),
                                                    content: const Text(
                                                        'Are you sure you want to reject this incident? This will permanently delete it from the database.'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, false),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, true),
                                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                      ),
                                                    ],
                                                  ),
                                                );

                                                if (confirm == true) {
                                                  await incidentProvider.deleteIncident(incident.id, admin.id, admin.name);
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident Rejected & Deleted')));
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        ]
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusFilterTabs(BuildContext context, IncidentProvider provider) {
    final statuses = ['All', 'Pending', 'Verified', 'Resolved', 'Rejected'];
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: statuses.map((status) {
          final isSelected = provider.filterStatus == status;
          return InkWell(
            onTap: () => provider.setFilter(status),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
