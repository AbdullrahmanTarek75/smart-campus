class ClassroomModel {
  final String id;
  final String name;
  final String building;
  final int floor;
  final int capacity;
  final String description;
  final List<String> facilities;
  final Map<String, dynamic>? coordinates;
  
  ClassroomModel({
    required this.id,
    required this.name,
    required this.building,
    required this.floor,
    required this.capacity,
    required this.description,
    required this.facilities,
    this.coordinates,
  });
  
  factory ClassroomModel.fromJson(Map<String, dynamic> json, String id) {
    return ClassroomModel(
      id: id,
      name: json['name'] ?? '',
      building: json['building'] ?? '',
      floor: json['floor'] ?? 0,
      capacity: json['capacity'] ?? 0,
      description: json['description'] ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      coordinates: json['coordinates'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'building': building,
      'floor': floor,
      'capacity': capacity,
      'description': description,
      'facilities': facilities,
      'coordinates': coordinates,
    };
  }
  
  ClassroomModel copyWith({
    String? id,
    String? name,
    String? building,
    int? floor,
    int? capacity,
    String? description,
    List<String>? facilities,
    Map<String, dynamic>? coordinates,
  }) {
    return ClassroomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      building: building ?? this.building,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      description: description ?? this.description,
      facilities: facilities ?? this.facilities,
      coordinates: coordinates ?? this.coordinates,
    );
  }
} 