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

  Vehicle copyWith({
    int? id,
    String? plateNumber,
    String? modelName,
    String? vehicleType,
    int? mileage,
    int? fuelLevel,
    String? status,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      modelName: modelName ?? this.modelName,
      vehicleType: vehicleType ?? this.vehicleType,
      mileage: mileage ?? this.mileage,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      status: status ?? this.status,
    );
  }
}
