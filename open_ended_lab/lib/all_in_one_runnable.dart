import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FleetProvider()),
      ],
      child: const AeroFleetApp(),
    ),
  );
}

class AeroFleetApp extends StatelessWidget {
  const AeroFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AeroFleet Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/vehicles': (context) => const VehicleListScreen(),
        '/add_vehicle': (context) => const AddEditVehicleScreen(),
        '/api_advisories': (context) => const ApiBulletinScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class Vehicle {
  final int? id;
  final String plateNumber;
  final String modelName;
  final String vehicleType;
  final int mileage;
  final int fuelLevel;
  final String status;

  Vehicle({
    this.id,
    required this.plateNumber,
    required this.modelName,
    required this.vehicleType,
    required this.mileage,
    required this.fuelLevel,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plateNumber': plateNumber,
      'modelName': modelName,
      'vehicleType': vehicleType,
      'mileage': mileage,
      'fuelLevel': fuelLevel,
      'status': status,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      plateNumber: map['plateNumber'] as String,
      modelName: map['modelName'] as String,
      vehicleType: map['vehicleType'] as String,
      mileage: map['mileage'] as int,
      fuelLevel: map['fuelLevel'] as int,
      status: map['status'] as String,
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fleet_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        plateNumber TEXT NOT NULL,
        modelName TEXT NOT NULL,
        vehicleType TEXT NOT NULL,
        mileage INTEGER NOT NULL,
        fuelLevel INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.insert('vehicles', {
      'plateNumber': 'FL-8092',
      'modelName': 'Volvo FH16 Heavy Hauler',
      'vehicleType': 'Cargo Truck',
      'mileage': 45200,
      'fuelLevel': 85,
      'status': 'Active'
    });
    await db.insert('vehicles', {
      'plateNumber': 'FL-4411',
      'modelName': 'Ford Transit Delivery',
      'vehicleType': 'Delivery Van',
      'mileage': 68100,
      'fuelLevel': 25,
      'status': 'Maintenance'
    });
    await db.insert('vehicles', {
      'plateNumber': 'FL-9903',
      'modelName': 'Isuzu D-Max Patrol',
      'vehicleType': 'Support Pickup',
      'mileage': 12400,
      'fuelLevel': 90,
      'status': 'Active'
    });
  }

  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.insert('vehicles', vehicle.toMap());
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final db = await database;
    final result = await db.query('vehicles', orderBy: 'id DESC');
    return result.map((map) => Vehicle.fromMap(map)).toList();
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

class SafetyBulletin {
  final int id;
  final String title;
  final String body;

  SafetyBulletin({
    required this.id,
    required this.title,
    required this.body,
  });

  factory SafetyBulletin.fromJson(Map<String, dynamic> json) {
    return SafetyBulletin(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class ApiService {
  static const String endpoint = 'https://jsonplaceholder.typicode.com/posts';

  Future<List<SafetyBulletin>> fetchSafetyBulletins() async {
    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.take(15).map((item) => SafetyBulletin.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load advisories');
    }
  }
}

class FleetProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  List<Vehicle> _vehicles = [];
  bool _isLoading = false;
  bool _isGridView = false;
  String _searchQuery = '';
  String _statusFilter = 'All';

  List<Vehicle> get vehicles {
    return _vehicles.where((vehicle) {
      final matchesSearch = vehicle.plateNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle.modelName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          vehicle.vehicleType.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus = _statusFilter == 'All' || vehicle.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  bool get isLoading => _isLoading;
  bool get isGridView => _isGridView;
  String get statusFilter => _statusFilter;

  int get totalCount => _vehicles.length;
  int get activeCount => _vehicles.where((v) => v.status == 'Active').length;
  int get maintenanceCount => _vehicles.where((v) => v.status == 'Maintenance').length;
  int get groundedCount => _vehicles.where((v) => v.status == 'Grounded').length;

  Future<void> loadVehicles() async {
    _isLoading = true;
    notifyListeners();
    _vehicles = await _dbHelper.getAllVehicles();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    await _dbHelper.insertVehicle(vehicle);
    await loadVehicles();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _dbHelper.updateVehicle(vehicle);
    await loadVehicles();
  }

  Future<void> deleteVehicle(int id) async {
    await _dbHelper.deleteVehicle(id);
    await loadVehicles();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _officerNameController = TextEditingController(text: 'Maaz Ali');
  final _badgeIdController = TextEditingController(text: 'FLEET-770');
  final _stationController = TextEditingController(text: 'Central Logistics Hub');
  bool _isLoading = false;

  @override
  void dispose() {
    _officerNameController.dispose();
    _badgeIdController.dispose();
    _stationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('officerName', _officerNameController.text.trim());
    await prefs.setString('badgeId', _badgeIdController.text.trim());
    await prefs.setString('station', _stationController.text.trim());

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.local_shipping, size: 64, color: Colors.indigo),
                    const SizedBox(height: 12),
                    const Text(
                      'AeroFleet Dispatcher',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Logistics & Maintenance Portal',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _officerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Fleet Officer Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Please enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _badgeIdController,
                      decoration: const InputDecoration(
                        labelText: 'Officer Badge ID',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Please enter badge ID' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stationController,
                      decoration: const InputDecoration(
                        labelText: 'Assigned Station / Hub',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Please enter station' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'AUTHORIZE & ENTER',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
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

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.teal;
      case 'Maintenance':
        return Colors.orange;
      case 'Grounded':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getVehicleIcon(String type) {
    switch (type) {
      case 'Cargo Truck':
        return Icons.local_shipping;
      case 'Delivery Van':
        return Icons.airport_shuttle;
      case 'Support Pickup':
        return Icons.directions_car;
      default:
        return Icons.commute;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fleet = context.watch<FleetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Vehicle Registry'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: fleet.isGridView ? 'Switch to List View' : 'Switch to Grid View',
            icon: Icon(fleet.isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => context.read<FleetProvider>().toggleViewMode(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FleetProvider>().loadVehicles(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search plate number, model, type...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (val) => context.read<FleetProvider>().setSearchQuery(val),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['All', 'Active', 'Maintenance', 'Grounded'].map((status) {
                final isSelected = fleet.statusFilter == status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(status),
                    selected: isSelected,
                    selectedColor: Colors.indigo.shade100,
                    checkmarkColor: Colors.indigo,
                    onSelected: (_) => context.read<FleetProvider>().setStatusFilter(status),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: fleet.isLoading
                ? const Center(child: CircularProgressIndicator())
                : fleet.vehicles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car_filled_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'No vehicles found in database',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => Navigator.pushNamed(context, '/add_vehicle'),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Vehicle Now'),
                            ),
                          ],
                        ),
                      )
                    : fleet.isGridView
                        ? _buildGridView(context, fleet.vehicles)
                        : _buildListView(context, fleet.vehicles),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Register Vehicle'),
        onPressed: () => Navigator.pushNamed(context, '/add_vehicle'),
      ),
    );
  }

  Widget _buildListView(BuildContext context, List<Vehicle> vehicles) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final v = vehicles[index];
        final statusColor = _getStatusColor(v.status);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: statusColor.withOpacity(0.15),
                  child: Icon(_getVehicleIcon(v.vehicleType), color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            v.plateNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              v.status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${v.modelName} • ${v.vehicleType}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.speed, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('${v.mileage} km', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 16),
                          Icon(Icons.local_gas_station, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text('${v.fuelLevel}% Fuel', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.pushNamed(context, '/add_vehicle', arguments: v);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, v);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.indigo),
                          SizedBox(width: 8),
                          Text('Edit Record'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete Unit'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridView(BuildContext context, List<Vehicle> vehicles) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final v = vehicles[index];
        final statusColor = _getStatusColor(v.status);

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pushNamed(context, '/add_vehicle', arguments: v),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: statusColor.withOpacity(0.15),
                        child: Icon(_getVehicleIcon(v.vehicleType), size: 18, color: statusColor),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          v.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    v.plateNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    v.modelName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${v.mileage} km',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: v.fuelLevel / 100.0,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      v.fuelLevel < 30 ? Colors.red : Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${v.fuelLevel}% Fuel',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                      InkWell(
                        onTap: () => _showDeleteDialog(context, v),
                        child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Permanently remove unit ${vehicle.plateNumber} from database?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              if (vehicle.id != null) {
                context.read<FleetProvider>().deleteVehicle(vehicle.id!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vehicle ${vehicle.plateNumber} deleted from SQLite')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AddEditVehicleScreen extends StatefulWidget {
  const AddEditVehicleScreen({super.key});

  @override
  State<AddEditVehicleScreen> createState() => _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends State<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _mileageController = TextEditingController();

  String _vehicleType = 'Cargo Truck';
  String _status = 'Active';
  double _fuelLevel = 80.0;
  Vehicle? _existingVehicle;
  bool _initialized = false;

  final List<String> _typeOptions = [
    'Cargo Truck',
    'Delivery Van',
    'Support Pickup',
    'Heavy Hauler'
  ];

  final List<String> _statusOptions = [
    'Active',
    'Maintenance',
    'Grounded'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Vehicle) {
        _existingVehicle = args;
        _plateController.text = args.plateNumber;
        _modelController.text = args.modelName;
        _mileageController.text = args.mileage.toString();
        _vehicleType = args.vehicleType;
        _status = args.status;
        _fuelLevel = args.fuelLevel.toDouble();
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (!_formKey.currentState!.validate()) return;

    final int mileage = int.tryParse(_mileageController.text.trim()) ?? 0;
    final int fuel = _fuelLevel.round();

    final vehicle = Vehicle(
      id: _existingVehicle?.id,
      plateNumber: _plateController.text.trim().toUpperCase(),
      modelName: _modelController.text.trim(),
      vehicleType: _vehicleType,
      mileage: mileage,
      fuelLevel: fuel,
      status: _status,
    );

    if (_existingVehicle == null) {
      context.read<FleetProvider>().addVehicle(vehicle);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New vehicle inserted into SQLite')),
      );
    } else {
      context.read<FleetProvider>().updateVehicle(vehicle);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle record updated in SQLite')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _existingVehicle != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Vehicle Record' : 'Register New Fleet Unit'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _plateController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Registration Plate Number',
                  hintText: 'e.g., FL-9821',
                  prefixIcon: Icon(Icons.pin),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter plate number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Model & Specification',
                  hintText: 'e.g., Volvo FH16 540',
                  prefixIcon: Icon(Icons.directions_car),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter vehicle model' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _vehicleType,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Fleet Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _typeOptions
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _vehicleType = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mileageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Current Odometer Mileage (km)',
                  prefixIcon: Icon(Icons.speed),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter mileage';
                  if (int.tryParse(val) == null) return 'Must be a valid integer';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Operational Fleet Status',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                ),
                items: _statusOptions
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Fuel Tank Level: ${_fuelLevel.round()}%',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Slider(
                value: _fuelLevel,
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: _fuelLevel < 30 ? Colors.red : Colors.teal,
                label: '${_fuelLevel.round()}%',
                onChanged: (val) => setState(() => _fuelLevel = val),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saveVehicle,
                icon: const Icon(Icons.save),
                label: Text(
                  isEditing ? 'UPDATE SQLITE RECORD' : 'SAVE TO SQLITE DATABASE',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ApiBulletinScreen extends StatefulWidget {
  const ApiBulletinScreen({super.key});

  @override
  State<ApiBulletinScreen> createState() => _ApiBulletinScreenState();
}

class _ApiBulletinScreenState extends State<ApiBulletinScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<SafetyBulletin>> _futureBulletins;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureBulletins = _apiService.fetchSafetyBulletins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Highway & Safety Feed (API)'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: FutureBuilder<List<SafetyBulletin>>(
        future: _futureBulletins,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.indigo),
                  SizedBox(height: 12),
                  Text('Fetching remote advisories from REST API...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'API Network Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.replay),
                      label: const Text('Retry Connection'),
                    ),
                  ],
                ),
              ),
            );
          }

          final bulletins = snapshot.data ?? [];
          if (bulletins.isEmpty) {
            return const Center(child: Text('No external advisories reported.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: bulletins.length,
              itemBuilder: (context, index) {
                final b = bulletins[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BULLETIN #${b.id}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.verified, size: 16, color: Colors.teal),
                            const SizedBox(width: 4),
                            const Text(
                              'Verified API',
                              style: TextStyle(fontSize: 11, color: Colors.teal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b.body,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _officerName = '';
  String _badgeId = '';
  String _station = '';
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _officerName = prefs.getString('officerName') ?? 'Not Set';
      _badgeId = prefs.getString('badgeId') ?? 'Not Set';
      _station = prefs.getString('station') ?? 'Not Set';
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _toggleDarkMode(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', val);
    setState(() => _darkMode = val);
  }

  Future<void> _toggleNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
    setState(() => _notifications = val);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session & Preferences'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.security, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        'Active Session (SharedPreferences)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildSessionRow('Officer Name', _officerName),
                  const SizedBox(height: 8),
                  _buildSessionRow('Badge ID', _badgeId),
                  const SizedBox(height: 8),
                  _buildSessionRow('Station Hub', _station),
                  const SizedBox(height: 8),
                  _buildSessionRow('Status', 'Authenticated Session'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode Preference'),
                  subtitle: const Text('Persisted locally in SharedPreferences'),
                  value: _darkMode,
                  onChanged: _toggleDarkMode,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined),
                  title: const Text('Dispatch Notifications'),
                  subtitle: const Text('Persisted locally in SharedPreferences'),
                  value: _notifications,
                  onChanged: _toggleNotifications,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT & CLEAR SESSION'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
