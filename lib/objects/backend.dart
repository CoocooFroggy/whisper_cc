import 'package:json_annotation/json_annotation.dart';

part 'backend.g.dart';

enum Backend {
  @JsonValue('estimation')
  queued,
  @JsonValue('process_starts')
  starting,
  @JsonValue('progress')
  running,
  @JsonValue('process_completed')
  completed,
}

const _backendEnumMap = {
  Backend.queued: 'estimation',
  Backend.starting: 'process_starts',
  Backend.running: 'progress',
  Backend.completed: 'process_completed',
};

@JsonSerializable()
class BackendStatus {
  @JsonKey(name: 'msg')
  final Backend backend;

  BackendStatus(this.backend);

  factory BackendStatus.fromJson(Map<String, dynamic> json) {
    final backend = $enumDecode(_backendEnumMap, json['msg']);
    switch (backend) {
      case Backend.queued: {
        return QueuedBackendStatus.fromJson(json);
      }
      case Backend.starting: {
        return StartingBackendStatus.fromJson(json);
      }
      case Backend.running: {
        return RunningBackendStatus.fromJson(json);
      }
      case Backend.completed: {
        return CompletedBackendStatus.fromJson(json);
      }
    }
  }
  Map<String, dynamic> toJson(instance) => _$BackendStatusToJson(this);
}

@JsonSerializable()
class QueuedBackendStatus extends BackendStatus {
  final int rank;
  @JsonKey(name: 'queue_size')
  final int queueSize;
  @JsonKey(name: 'rank_eta')
  final double rankEta;

  QueuedBackendStatus(super.backend, {required this.rank, required this.queueSize, required this.rankEta});

  factory QueuedBackendStatus.fromJson(Map<String, dynamic> json) => _$QueuedBackendStatusFromJson(json);
  @override
  Map<String, dynamic> toJson(instance) => _$QueuedBackendStatusToJson(this);
}

@JsonSerializable()
class StartingBackendStatus extends BackendStatus {
  StartingBackendStatus(super.backend);

  factory StartingBackendStatus.fromJson(Map<String, dynamic> json) => _$StartingBackendStatusFromJson(json);
  @override
  Map<String, dynamic> toJson(instance) => _$StartingBackendStatusToJson(this);
}

@JsonSerializable()
class RunningBackendStatus extends BackendStatus {
  @JsonKey(name: 'progress_data')
  final List<Map<String, dynamic>> progressData;

  RunningBackendStatus(super.backend, {required this.progressData});

  factory RunningBackendStatus.fromJson(Map<String, dynamic> json) => _$RunningBackendStatusFromJson(json);
  @override
  Map<String, dynamic> toJson(instance) => _$RunningBackendStatusToJson(this);
}

@JsonSerializable()
class CompletedBackendStatus extends BackendStatus {
  @JsonKey(fromJson: outputFromJson)
  final String output;

  CompletedBackendStatus(super.backend, {required this.output});

  factory CompletedBackendStatus.fromJson(Map<String, dynamic> json) => _$CompletedBackendStatusFromJson(json);
  @override
  Map<String, dynamic> toJson(instance) => _$CompletedBackendStatusToJson(this);
}

String outputFromJson(dynamic json) {
  return json['data'][1];
}