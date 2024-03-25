class BF600MeasurementData {
  final double weight;

  BF600MeasurementData({
    this.weight = 0.0,
  });

  BF600MeasurementData copyWith({
    double? weight,
  }) {
    return BF600MeasurementData(
      weight: weight ?? this.weight,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'weight': weight,
    };
  }

  factory BF600MeasurementData.fromMap(Map<String, dynamic> map) {
    return BF600MeasurementData(
      weight: (map['weight'] ?? 0.0) as double,
    );
  }

  @override
  bool operator ==(covariant BF600MeasurementData other) {
    if (identical(this, other)) return true;

    return other.weight == weight;
  }

  @override
  int get hashCode => weight.hashCode;
}
