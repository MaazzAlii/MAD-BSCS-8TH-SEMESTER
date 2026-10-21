import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/fleet_provider.dart';

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
