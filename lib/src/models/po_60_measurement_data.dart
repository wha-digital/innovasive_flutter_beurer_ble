import 'package:flutter/foundation.dart';

class PO60MeasurementData {
  final DateTime start;
  final DateTime end;
  final int storageTimePeriod;
  final int sp02Max;
  final int sp02Min;
  final int sp02Avg;
  final int prMax;
  final int prMin;
  final int prAvg;
  final List<int> rawData; // for debug

  PO60MeasurementData({
    required this.start,
    required this.end,
    required this.storageTimePeriod,
    required this.sp02Max,
    required this.sp02Min,
    required this.sp02Avg,
    required this.prMax,
    required this.prMin,
    required this.prAvg,
    this.rawData = const [],
  });

  PO60MeasurementData copyWith({
    DateTime? start,
    DateTime? end,
    int? storageTimePeriod,
    int? sp02Max,
    int? sp02Min,
    int? sp02Avg,
    int? prMax,
    int? prMin,
    int? prAvg,
    List<int>? rawData,
  }) {
    return PO60MeasurementData(
      start: start ?? this.start,
      end: end ?? this.end,
      storageTimePeriod: storageTimePeriod ?? this.storageTimePeriod,
      sp02Max: sp02Max ?? this.sp02Max,
      sp02Min: sp02Min ?? this.sp02Min,
      sp02Avg: sp02Avg ?? this.sp02Avg,
      prMax: prMax ?? this.prMax,
      prMin: prMin ?? this.prMin,
      prAvg: prAvg ?? this.prAvg,
      rawData: rawData ?? this.rawData,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'start': start.millisecondsSinceEpoch,
      'end': end.millisecondsSinceEpoch,
      'storageTimePeriod': storageTimePeriod,
      'sp02Max': sp02Max,
      'sp02Min': sp02Min,
      'sp02Avg': sp02Avg,
      'prMax': prMax,
      'prMin': prMin,
      'prAvg': prAvg,
      'rawData': rawData,
    };
  }

  factory PO60MeasurementData.fromMap(Map<String, dynamic> map) {
    return PO60MeasurementData(
      start: DateTime.fromMillisecondsSinceEpoch((map['start'] ?? 0) as int),
      end: DateTime.fromMillisecondsSinceEpoch((map['end'] ?? 0) as int),
      storageTimePeriod: (map['storageTimePeriod'] ?? 0) as int,
      sp02Max: (map['sp02Max'] ?? 0) as int,
      sp02Min: (map['sp02Min'] ?? 0) as int,
      sp02Avg: (map['sp02Avg'] ?? 0) as int,
      prMax: (map['prMax'] ?? 0) as int,
      prMin: (map['prMin'] ?? 0) as int,
      prAvg: (map['prAvg'] ?? 0) as int,
      rawData: List<int>.from((map['rawData'] ?? const <int>[]) as List<int>),
    );
  }

  @override
  bool operator ==(covariant PO60MeasurementData other) {
    if (identical(this, other)) return true;

    return other.start == start &&
        other.end == end &&
        other.storageTimePeriod == storageTimePeriod &&
        other.sp02Max == sp02Max &&
        other.sp02Min == sp02Min &&
        other.sp02Avg == sp02Avg &&
        other.prMax == prMax &&
        other.prMin == prMin &&
        other.prAvg == prAvg &&
        listEquals(other.rawData, rawData);
  }

  @override
  int get hashCode {
    return start.hashCode ^
        end.hashCode ^
        storageTimePeriod.hashCode ^
        sp02Max.hashCode ^
        sp02Min.hashCode ^
        sp02Avg.hashCode ^
        prMax.hashCode ^
        prMin.hashCode ^
        prAvg.hashCode ^
        rawData.hashCode;
  }
}
