import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';

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

  Future close() async {
    final db = await database;
    db.close();
  }
}
