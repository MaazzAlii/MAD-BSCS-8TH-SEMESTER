import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/vehicle.dart';

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

  List<Vehicle> get rawList => _vehicles;
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
