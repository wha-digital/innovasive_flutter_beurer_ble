// ignore_for_file: public_member_api_docs, sort_constructors_first
class FT95MeasurementData {
  final int flags;
  final DateTime timestamp;
  final double temperature;
  final int type;

  FT95MeasurementData({
    required this.flags,
    required this.timestamp,
    required this.temperature,
    required this.type,
  });

  FT95MeasurementData copyWith({
    int? flags,
    DateTime? timestamp,
    double? temperature,
    int? type,
  }) {
    return FT95MeasurementData(
      flags: flags ?? this.flags,
      timestamp: timestamp ?? this.timestamp,
      temperature: temperature ?? this.temperature,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'flags': flags,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'temperature': temperature,
      'type': type,
    };
  }

  factory FT95MeasurementData.fromMap(Map<String, dynamic> map) {
    return FT95MeasurementData(
      flags: (map['flags'] ?? 0) as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch((map['timestamp'] ?? 0) as int),
      temperature: (map['temperature'] ?? 0.0) as double,
      type: (map['type'] ?? 0) as int,
    );
  }

  @override
  bool operator ==(covariant FT95MeasurementData other) {
    if (identical(this, other)) return true;

    return other.flags == flags && other.timestamp == timestamp && other.temperature == temperature && other.type == type;
  }

  @override
  int get hashCode {
    return flags.hashCode ^ timestamp.hashCode ^ temperature.hashCode ^ type.hashCode;
  }
}
