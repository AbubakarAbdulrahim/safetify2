import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/custom_button.dart';
import '../../services/firestore_service.dart';
import '../../models/alert_model.dart';
import '../../models/community_update_model.dart';
import '../../utils/helpers.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  // Alert Form Keys & Controllers
  final _alertFormKey = GlobalKey<FormState>();
  final _alertTitleController = TextEditingController();
  final _alertMessageController = TextEditingController();
  
  // Community Update Form Keys & Controllers
  final _updateFormKey = GlobalKey<FormState>();
  final _updateTitleController = TextEditingController();
  final _updateDescController = TextEditingController();
  final _updateLocationController = TextEditingController();
  
  String _selectedCategory = 'Info';
  String _selectedPriority = 'Info';
  DateTime? _selectedDate;
  
  bool _isLoading = false;

  final List<String> _categories = ['Safety', 'Event', 'Alert', 'Maintenance', 'Info'];
  final List<String> _priorities = ['Urgent', 'Important', 'Info'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _alertTitleController.dispose();
    _alertMessageController.dispose();
    _updateTitleController.dispose();
    _updateDescController.dispose();
    _updateLocationController.dispose();
    super.dispose();
  }

  Future<void> _sendAlert() async {
    if (_alertFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final alert = AlertModel(
          id: '',
          title: _alertTitleController.text,
          message: _alertMessageController.text,
          type: 'manual',
          sentAt: DateTime.now(),
        );
        await _firestoreService.sendAlert(alert);
        _showSnackbar('Alert sent successfully');
        _alertTitleController.clear();
        _alertMessageController.clear();
      } catch (e) {
        _showSnackbar('Error sending alert: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendCommunityUpdate() async {
    if (_updateFormKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final update = CommunityUpdate(
          id: '', // Firestore generates
          title: _updateTitleController.text,
          description: _updateDescController.text,
          category: _selectedCategory,
          priority: _selectedPriority,
          location: _updateLocationController.text.isNotEmpty ? _updateLocationController.text : null,
          eventDate: _selectedDate,
          createdAt: DateTime.now(),
        );
        await _firestoreService.sendCommunityUpdate(update);
        _showSnackbar('Community Update sent successfully');
        _updateTitleController.clear();
        _updateDescController.clear();
        _updateLocationController.clear();
        setState(() {
          _selectedCategory = 'Info';
          _selectedPriority = 'Info';
          _selectedDate = null;
        });
      } catch (e) {
        _showSnackbar('Error sending update: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Communication Center',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).colorScheme.primary,
            tabs: const [
              Tab(text: 'Safety Alerts', icon: Icon(Icons.warning_amber)),
              Tab(text: 'Community Updates', icon: Icon(Icons.campaign)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSafetyAlertsTab(),
              _buildCommunityUpdatesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyAlertsTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: CustomCard(
            child: Form(
              key: _alertFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Send Emergency Alert', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _alertTitleController,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _alertMessageController,
                    decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
                    maxLines: 3,
                    validator: (value) => value!.isEmpty ? 'Message is required' : null,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Broadcast Alert',
                    color: Colors.red,
                    onPressed: _sendAlert,
                    isLoading: _isLoading,
                  ),
                ],
              ),
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
                Text('Recent Alerts', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<List<AlertModel>>(
                    stream: _firestoreService.getAlerts(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final alerts = snapshot.data!;
                      if (alerts.isEmpty) return const Text('No alerts sent yet.');
                      return ListView.separated(
                        itemCount: alerts.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final alert = alerts[index];
                          return ListTile(
                            title: Text(alert.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(alert.message),
                            trailing: Text(Helpers.formatShortDate(alert.sentAt)),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityUpdatesTab() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: CustomCard(
            child: Form(
              key: _updateFormKey,
              child: ListView(
                // Use ListView to allow scrolling if form is long
                shrinkWrap: true,
                children: [
                  Text('Compose Update', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _updateTitleController,
                    decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _updateDescController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 4,
                    validator: (value) => value!.isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedPriority,
                          decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                          items: _priorities.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                          onChanged: (v) => setState(() => _selectedPriority = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _updateLocationController,
                    decoration: const InputDecoration(labelText: 'Location (Optional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.place)),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Event Date (Optional)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                      child: Text(_selectedDate == null ? 'Select Date' : DateFormat('MMM d, yyyy').format(_selectedDate!)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Post Update',
                    onPressed: _sendCommunityUpdate,
                    isLoading: _isLoading,
                  ),
                ],
              ),
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
                Text('Recent Updates', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<List<CommunityUpdate>>(
                    stream: _firestoreService.getCommunityUpdates(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final updates = snapshot.data!;
                      if (updates.isEmpty) return const Text('No updates posted yet.');
                      return ListView.separated(
                        itemCount: updates.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final update = updates[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(update.category[0]),
                            ),
                            title: Text(update.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${update.priority} • ${update.category}'),
                            trailing: Text(Helpers.formatShortDate(update.createdAt)),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
