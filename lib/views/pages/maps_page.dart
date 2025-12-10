import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/incident_provider.dart';
import '../../widgets/custom_card.dart';

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final incidentProvider = Provider.of<IncidentProvider>(context);
    final incidents = incidentProvider.incidents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Real-Time Map',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        Expanded(
          child: CustomCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: const LatLng(12.0022, 8.5920), // Kano coordinates
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.safetify.admin',
                  ),
                  MarkerLayer(
                    markers: incidents.map((incident) {
                      return Marker(
                        point: incident.location,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(incident.title),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Status: ${incident.status}'),
                                    Text('Category: ${incident.category}'),
                                    const SizedBox(height: 8),
                                    Text(incident.description),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Icon(
                            Icons.location_on,
                            color: _getMarkerColor(incident.status),
                            size: 40,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
}
