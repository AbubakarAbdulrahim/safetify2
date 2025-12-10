import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/incident_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/incident.dart';
import '../../widgets/custom_card.dart';
import 'package:intl/intl.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _timeRange = 'All Time'; // 'Last 7 Days', 'Last 30 Days', 'All Time'

  @override
  Widget build(BuildContext context) {
    final incidentProvider = Provider.of<IncidentProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    // Filter incidents based on time range
    List<Incident> filteredIncidents = incidentProvider.incidents;
    if (_timeRange == 'Last 7 Days') {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      filteredIncidents = filteredIncidents.where((i) => i.createdAt.isAfter(sevenDaysAgo)).toList();
    } else if (_timeRange == 'Last 30 Days') {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      filteredIncidents = filteredIncidents.where((i) => i.createdAt.isAfter(thirtyDaysAgo)).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _timeRange,
                    items: ['Last 7 Days', 'Last 30 Days', 'All Time']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _timeRange = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // KPI Cards
          _buildKPICards(context, filteredIncidents, userProvider.users.length),
          const SizedBox(height: 24),

          // Charts Row 1
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Incident Status', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 24),
                      AspectRatio(
                        aspectRatio: 1.3,
                        child: _buildStatusPieChart(filteredIncidents),
                      ),
                      const SizedBox(height: 16),
                      _buildStatusLegend(),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weekly Trends (Last 7 Days)', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 24),
                      AspectRatio(
                        aspectRatio: 2,
                        child: _buildWeeklyBarChart(context, incidentProvider.incidents), // Always show full week trend context or filtered? Let's use filtered if it makes sense, but 'Weekly Trends' usually implies last 7 days explicitly.
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Charts Row 2: Categories
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Incidents by Category', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                _buildCategoryStats(context, filteredIncidents),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Charts Row 3: Locations
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Top Incident Locations', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 24),
                _buildLocationStats(context, filteredIncidents),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICards(BuildContext context, List<Incident> incidents, int totalUsers) {
    final total = incidents.length;
    final verified = incidents.where((i) => i.status == 'verified').length;
    final resolved = incidents.where((i) => i.status == 'resolved').length;
    final pending = incidents.where((i) => i.status == 'pending').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            _buildKPIItem(context, 'Total Incidents', '$total', Icons.analytics, Colors.blue),
            const SizedBox(width: 16),
            _buildKPIItem(context, 'Pending', '$pending', Icons.pending_actions, Colors.orange),
            const SizedBox(width: 16),
            _buildKPIItem(context, 'Resolved', '$resolved', Icons.check_circle, Colors.green),
            const SizedBox(width: 16),
            _buildKPIItem(context, 'Active Users', '$totalUsers', Icons.people, Colors.purple),
          ],
        );
      },
    );
  }

  Widget _buildKPIItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Expanded(
      child: CustomCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPieChart(List<Incident> incidents) {
    final total = incidents.length;
    if (total == 0) return const Center(child: Text('No data'));

    final verified = incidents.where((i) => i.status == 'verified').length;
    final pending = incidents.where((i) => i.status == 'pending').length;
    final resolved = incidents.where((i) => i.status == 'resolved').length;
    final fake = incidents.where((i) => i.status == 'fake' || i.status == 'rejected').length;

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          if (verified > 0) _buildPieSection(verified, 'Verified', Colors.green, total),
          if (pending > 0) _buildPieSection(pending, 'Pending', Colors.orange, total),
          if (resolved > 0) _buildPieSection(resolved, 'Resolved', Colors.blue, total),
          if (fake > 0) _buildPieSection(fake, 'Rejected', Colors.red, total),
        ],
      ),
    );
  }

  PieChartSectionData _buildPieSection(int value, String title, Color color, int total) {
    final double percentage = (value / total) * 100;
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: '${percentage.toStringAsFixed(1)}%',
      radius: 50,
      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _buildStatusLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Verified', Colors.green),
        _buildLegendItem('Pending', Colors.orange),
        _buildLegendItem('Resolved', Colors.blue),
        _buildLegendItem('Rejected', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildWeeklyBarChart(BuildContext context, List<Incident> incidents) {
    // Generate last 7 days logic
    final Map<int, int> daysCounts = {};
    final now = DateTime.now();
    
    // Initialize last 7 days with 0
    for (int i = 6; i >= 0; i--) {
      daysCounts[i] = 0; // 0 = today, 1 = yesterday... 6 = 7 days ago
    }

    // Count incidents
    for (var incident in incidents) {
      final diff = now.difference(incident.createdAt).inDays;
      if (diff >= 0 && diff < 7) {
        daysCounts[diff] = (daysCounts[diff] ?? 0) + 1;
      }
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (daysCounts.values.fold(0, (p, c) => c > p ? c : p) + 5).toDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // value corresponds to x axis index.
                // We reversed the order: index 0 = 6 days ago, index 6 = today ? NO.
                // Let's allow index 0 = 6 days ago.
                
                final int daysAgo = 6 - value.toInt();
                final date = now.subtract(Duration(days: daysAgo));
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(DateFormat('E').format(date)), // Mon, Tue...
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(7, (index) {
           // index 0 -> 6 days ago (diff=6)
           // index 6 -> today (diff=0)
           final diff = 6 - index;
           final count = daysCounts[diff] ?? 0;
           
           return BarChartGroupData(
             x: index,
             barRods: [
               BarChartRodData(
                 toY: count.toDouble(),
                 color: Theme.of(context).colorScheme.primary,
                 width: 16,
                 borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
               ),
             ],
           );
        }),
      ),
    );
  }
  
  Widget _buildCategoryStats(BuildContext context, List<Incident> incidents) {
     final Map<String, int> categoryCounts = {};
     for (var i in incidents) {
       categoryCounts[i.category] = (categoryCounts[i.category] ?? 0) + 1;
     }

     if (categoryCounts.isEmpty) return const Text('No data');
     
     // Sort by count descending
     final sortedEntries = categoryCounts.entries.toList()
       ..sort((a, b) => b.value.compareTo(a.value));
     
     final maxCount = sortedEntries.first.value;

     return Column(
       children: sortedEntries.map((entry) {
         return _buildStatRow(context, entry.key, entry.value, maxCount);
       }).toList(),
     );
  }

  Widget _buildLocationStats(BuildContext context, List<Incident> incidents) {
    final Map<String, int> locationCounts = {};
    for (var i in incidents) {
      if (i.locationName.isNotEmpty) {
        locationCounts[i.locationName] = (locationCounts[i.locationName] ?? 0) + 1;
      }
    }

    if (locationCounts.isEmpty) return const Text('No location data');

    // Sort by count descending and take top 5
    final sortedEntries = locationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topEntries = sortedEntries.take(5).toList();
    final maxCount = topEntries.first.value;

    return Column(
      children: topEntries.map((entry) {
        return _buildStatRow(context, entry.key, entry.value, maxCount);
      }).toList(),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, int count, int max) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 120, // Increased width for longer names
            child: Text(
              label, 
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: max > 0 ? count / max : 0,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 40,
            child: Text('$count', textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
