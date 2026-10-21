import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  final List<Vehicle> _webVehicles = [
    Vehicle(
      id: 1,
      plateNumber: 'FL-8092',
      modelName: 'Volvo FH16 Heavy Hauler',
      vehicleType: 'Cargo Truck',
      mileage: 45200,
      fuelLevel: 85,
      status: 'Active',
    ),
    Vehicle(
      id: 2,
      plateNumber: 'FL-4411',
      modelName: 'Ford Transit Delivery',
      vehicleType: 'Delivery Van',
      mileage: 68100,
      fuelLevel: 25,
      status: 'Maintenance',
    ),
    Vehicle(
      id: 3,
      plateNumber: 'FL-9903',
      modelName: 'Isuzu D-Max Patrol',
      vehicleType: 'Support Pickup',
      mileage: 12400,
      fuelLevel: 90,
      status: 'Active',
    ),
  ];
  int _webNextId = 4;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fleet_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

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

    for (var v in _webVehicles) {
      await db.insert('vehicles', v.toMap());
    }
  }

  Future<int> insertVehicle(Vehicle vehicle) async {
    if (kIsWeb) {
      final newVehicle = vehicle.copyWith(id: _webNextId++);
      _webVehicles.insert(0, newVehicle);
      return newVehicle.id!;
    }
    final db = await database;
    return await db.insert('vehicles', vehicle.toMap());
  }

  Future<List<Vehicle>> getAllVehicles() async {
    if (kIsWeb) {
      return List<Vehicle>.from(_webVehicles);
    }
    final db = await database;
    final result = await db.query('vehicles', orderBy: 'id DESC');
    return result.map((map) => Vehicle.fromMap(map)).toList();
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    if (kIsWeb) {
      final index = _webVehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        _webVehicles[index] = vehicle;
        return 1;
      }
      return 0;
    }
    final db = await database;
    return await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(int id) async {
    if (kIsWeb) {
      _webVehicles.removeWhere((v) => v.id == id);
      return 1;
    }
    final db = await database;
    return await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    if (kIsWeb) return;
    final db = await database;
    db.close();
  }
}
