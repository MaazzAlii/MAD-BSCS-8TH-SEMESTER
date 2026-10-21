import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/fleet_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _officerName = 'Fleet Officer';
  String _station = 'Logistics Hub';

  @override
  void initState() {
    super.initState();
    _loadSessionInfo();
    Future.microtask(() => context.read<FleetProvider>().loadVehicles());
  }

  Future<void> _loadSessionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _officerName = prefs.getString('officerName') ?? 'Fleet Officer';
      _station = prefs.getString('station') ?? 'Logistics Hub';
    });
  }

  @override
  Widget build(BuildContext context) {
    final fleet = context.watch<FleetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Command Center'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FleetProvider>().loadVehicles(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.indigo),
              accountName: Text(_officerName),
              accountEmail: Text('Station: $_station'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.local_shipping, color: Colors.indigo, size: 36),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Vehicle Registry (List & Grid)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/vehicles');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Register New Vehicle'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add_vehicle');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: const Text('Safety Advisories (Live API)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/api_advisories');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Session & Preferences'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
      ),
      body: fleet.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<FleetProvider>().loadVehicles(),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    color: Colors.indigo.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.indigo,
                            child: Icon(Icons.badge, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, $_officerName',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Duty Hub: $_station',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Operational Summary (Live SQLite)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetricCard(
                        title: 'Total Fleet',
                        count: fleet.totalCount.toString(),
                        icon: Icons.airport_shuttle,
                        color: Colors.indigo,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        title: 'Active Service',
                        count: fleet.activeCount.toString(),
                        icon: Icons.check_circle,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildMetricCard(
                        title: 'In Maintenance',
                        count: fleet.maintenanceCount.toString(),
                        icon: Icons.build_circle,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      _buildMetricCard(
                        title: 'Grounded / Inactive',
                        count: fleet.groundedCount.toString(),
                        icon: Icons.warning,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Quick Operational Controls',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildNavActionTile(
                    title: 'Vehicle Fleet Registry',
                    subtitle: 'Inspect all units in ListView or GridView',
                    icon: Icons.grid_view,
                    color: Colors.indigo,
                    onTap: () => Navigator.pushNamed(context, '/vehicles'),
                  ),
                  const SizedBox(height: 10),
                  _buildNavActionTile(
                    title: 'Add New Fleet Vehicle',
                    subtitle: 'Store new carrier directly into SQLite database',
                    icon: Icons.add_circle,
                    color: Colors.teal,
                    onTap: () => Navigator.pushNamed(context, '/add_vehicle'),
                  ),
                  const SizedBox(height: 10),
                  _buildNavActionTile(
                    title: 'Live Highway Safety Advisories',
                    subtitle: 'Fetch external regulatory bulletins via REST API',
                    icon: Icons.cloud_download,
                    color: Colors.blueGrey,
                    onTap: () => Navigator.pushNamed(context, '/api_advisories'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
