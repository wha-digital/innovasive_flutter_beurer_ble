// ignore_for_file: public_member_api_docs, sort_constructors_first
class BM77MeasurementData {
  final int flags;
  final int systolic;
  final int diastolic;
  final DateTime timestamp;
  final int pulseRate;
  final int userID;
  final String measurementStatus;

  BM77MeasurementData({
    required this.flags,
    required this.systolic,
    required this.diastolic,
    required this.timestamp,
    required this.pulseRate,
    required this.userID,
    required this.measurementStatus,
  });

  BM77MeasurementData copyWith({
    int? flags,
    int? systolic,
    int? diastolic,
    DateTime? timestamp,
    int? pulseRate,
    int? userID,
    String? measurementStatus,
  }) {
    return BM77MeasurementData(
      flags: flags ?? this.flags,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      timestamp: timestamp ?? this.timestamp,
      pulseRate: pulseRate ?? this.pulseRate,
      userID: userID ?? this.userID,
      measurementStatus: measurementStatus ?? this.measurementStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'flags': flags,
      'systolic': systolic,
      'diastolic': diastolic,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'pulseRate': pulseRate,
      'userID': userID,
      'measurementStatus': measurementStatus,
    };
  }

  factory BM77MeasurementData.fromMap(Map<String, dynamic> map) {
    return BM77MeasurementData(
      flags: (map['flags'] ?? 0) as int,
      systolic: (map['systolic'] ?? 0) as int,
      diastolic: (map['diastolic'] ?? 0) as int,
      timestamp: DateTime.fromMillisecondsSinceEpoch((map['timestamp'] ?? 0) as int),
      pulseRate: (map['pulseRate'] ?? 0) as int,
      userID: (map['userID'] ?? 0) as int,
      measurementStatus: (map['measurementStatus'] ?? '') as String,
    );
  }

  @override
  bool operator ==(covariant BM77MeasurementData other) {
    if (identical(this, other)) return true;

    return other.flags == flags &&
        other.systolic == systolic &&
        other.diastolic == diastolic &&
        other.timestamp == timestamp &&
        other.pulseRate == pulseRate &&
        other.userID == userID &&
        other.measurementStatus == measurementStatus;
  }

  @override
  int get hashCode {
    return flags.hashCode ^
        systolic.hashCode ^
        diastolic.hashCode ^
        timestamp.hashCode ^
        pulseRate.hashCode ^
        userID.hashCode ^
        measurementStatus.hashCode;
  }
}
