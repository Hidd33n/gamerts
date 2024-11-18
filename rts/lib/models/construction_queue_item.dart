// lib/models/construction_queue_item.dart

import 'package:equatable/equatable.dart';

class ConstructionQueueItem extends Equatable {
  final String buildingName;
  final DateTime finishTime;
  final Duration duration;

  const ConstructionQueueItem({
    required this.buildingName,
    required this.finishTime,
    required this.duration,
  });

  ConstructionQueueItem copyWith({
    String? buildingName,
    DateTime? finishTime,
    Duration? duration,
  }) {
    return ConstructionQueueItem(
      buildingName: buildingName ?? this.buildingName,
      finishTime: finishTime ?? this.finishTime,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [buildingName, finishTime, duration];
}
