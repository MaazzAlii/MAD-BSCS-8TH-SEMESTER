import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../providers/fleet_provider.dart';

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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                            Icon(Icons.directions_car_filled_outlined,
                                size: 64, color: Colors.grey.shade400),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
