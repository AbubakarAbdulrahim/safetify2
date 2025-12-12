import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/skeleton_container.dart';
import '../../widgets/empty_state_widget.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final incidentProvider = Provider.of<IncidentProvider>(context);
    final user = authProvider.currentUser;
    final incidents = incidentProvider.incidents;
    final isLoading = incidentProvider.isLoading;

    // Filter for recent incidents (e.g., last 5)
    final recentIncidents = incidents.take(5).toList();
    final pendingCount = incidents.where((i) => i.status == 'pending').length;
    final verifiedCount = incidents.where((i) => i.status == 'verified').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Welcome Banner
          _buildWelcomeBanner(context, user?.name ?? 'Admin'),
          const SizedBox(height: 24),

          // 2. Stats Row
          if (isLoading)
            const Row(
              children: [
                Expanded(child: SkeletonContainer(width: double.infinity, height: 140)),
                SizedBox(width: 16),
                Expanded(child: SkeletonContainer(width: double.infinity, height: 140)),
                SizedBox(width: 16),
                Expanded(child: SkeletonContainer(width: double.infinity, height: 140)),
              ],
            )
          else
            Row(
              children: [
                _buildStatCard(context, 'Total Incidents', '${incidents.length}', Icons.folder_open, Colors.blue),
                const SizedBox(width: 16),
                _buildStatCard(context, 'Needs Attention', '$pendingCount', Icons.warning_amber_rounded, Colors.orange),
                const SizedBox(width: 16),
                _buildStatCard(context, 'Verified Safe', '$verifiedCount', Icons.check_circle, Colors.green),
              ],
            ),
          const SizedBox(height: 24),

          // 3. Main Grid (Map + Actions vs Feed)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column (Map & Actions)
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Map Preview
                    CustomCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Live Map Preview', style: Theme.of(context).textTheme.titleLarge),
                                TextButton(
                                  onPressed: () => context.go('/map'),
                                  child: const Text('View Full Map'),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 300,
                            child: isLoading 
                              ? const SkeletonContainer(width: double.infinity, height: 300, borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)))
                              : ClipRRect(
                                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                                  child: FlutterMap(
                                    options: MapOptions(
                                      initialCenter: incidents.isNotEmpty 
                                          ? incidents.first.location 
                                          : const LatLng(12.0022, 8.5920),
                                      initialZoom: 12.0,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'com.safetify.admin',
                                      ),
                                      MarkerLayer(
                                        markers: incidents.take(10).map((incident) {
                                          return Marker(
                                            point: incident.location,
                                            width: 30,
                                            height: 30,
                                            child: Icon(
                                              Icons.location_on,
                                              color: _getMarkerColor(incident.status),
                                              size: 30,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Quick Actions
                    CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Broadcast Alert',
                                  icon: Icons.campaign,
                                  onPressed: () => context.go('/alerts'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomButton(
                                  text: 'Verify Incidents',
                                  icon: Icons.fact_check,
                                  color: Colors.green,
                                  onPressed: () => context.go('/incidents'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // Right Column (Recent Activity)
              Expanded(
                flex: 1,
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      if (isLoading)
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 5,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) => const Row(
                            children: [
                              SkeletonContainer.circular(size: 40),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SkeletonContainer(width: 120, height: 16),
                                    SizedBox(height: 8),
                                    SkeletonContainer(width: 80, height: 12),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      else if (recentIncidents.isEmpty)
                         const EmptyStateWidget(
                          title: 'No Recent Activity',
                          message: 'New incidents and updates will appear here.',
                          icon: Icons.notifications_off_outlined,
                         )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: recentIncidents.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final incident = recentIncidents[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: _getMarkerColor(incident.status).withOpacity(0.1),
                                child: Icon(_getCategoryIcon(incident.category), color: _getMarkerColor(incident.status), size: 20),
                              ),
                              title: Text(incident.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                '${DateFormat('MMM d, h:mm a').format(incident.createdAt)}\n${incident.locationName}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12),
                              ),
                              isThreeLine: true,
                              onTap: () => context.go('/incidents/${incident.id}'),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_getGreeting()}, $userName 👋',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Here is what\'s happening in your city today.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+12%', // Mock trend
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMarkerColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'resolved':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'rejected':
      case 'fake':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'accident': return Icons.car_crash;
      case 'fire': return Icons.local_fire_department;
      case 'medical': return Icons.medical_services;
      case 'theft': return Icons.local_police;
      default: return Icons.report_problem;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}
