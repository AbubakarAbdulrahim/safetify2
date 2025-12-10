import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/incident_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/status_badge.dart';
import '../../utils/helpers.dart';

class IncidentDetailsPage extends StatelessWidget {
  final String incidentId;

  const IncidentDetailsPage({super.key, required this.incidentId});

  @override
  Widget build(BuildContext context) {
    final incidentProvider = Provider.of<IncidentProvider>(context);
    final incident = incidentProvider.incidents.firstWhere(
      (i) => i.id == incidentId,
      orElse: () => throw Exception('Incident not found'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/incidents'),
            ),
            const SizedBox(width: 8),
            Text(
              'Incident Details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          incident.title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        StatusBadge(status: incident.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reported on ${Helpers.formatDate(incident.timestamp)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          incident.locationName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(incident.description),
                    const SizedBox(height: 24),
                    if (incident.imageUrl != null) ...[
                      Text(
                        'Image',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                backgroundColor: Colors.black,
                                appBar: AppBar(
                                  backgroundColor: Colors.black,
                                  iconTheme: const IconThemeData(color: Colors.white),
                                ),
                                body: Center(
                                  child: InteractiveViewer(
                                    child: Image.network(
                                      incident.imageUrl!,
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            incident.imageUrl!,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 1,
              child: CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    if (incident.status == 'pending') ...[
                      CustomButton(
                        text: 'Approve Incident',
                        color: Colors.green,
                        onPressed: () {
                          final admin = Provider.of<AuthProvider>(context, listen: false).currentUser;
                          if (admin != null) {
                            incidentProvider.updateStatus(incidentId, 'verified', admin.id, admin.name);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Reject Incident',
                        color: Colors.red,
                        onPressed: () async {
                          // Confirm deletion
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
                            final admin = Provider.of<AuthProvider>(context, listen: false).currentUser;
                            if (admin != null) {
                              await incidentProvider.deleteIncident(incidentId, admin.id, admin.name);
                              if (context.mounted) {
                                context.go('/incidents');
                              }
                            }
                          }
                        },
                      ),
                    ],
                    if (incident.status == 'verified')
                      CustomButton(
                        text: 'Mark as Resolved',
                        color: Colors.blue,
                        onPressed: () {
                          final admin = Provider.of<AuthProvider>(context, listen: false).currentUser;
                          if (admin != null) {
                            incidentProvider.updateStatus(incidentId, 'resolved', admin.id, admin.name);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
