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

@JsonSerializable()
class BackendStatus {
  @JsonKey(name: 'msg')
  final Backend backend;

  BackendStatus(this.backend);

  factory BackendStatus.fromJson(Map<String, dynamic> json) {
    // Return a different inherited object depending on `backend` enum
    switch (_$BackendStatusFromJson(json).backend) {
      case Backend.queued:
        {
          return QueuedBackendStatus.fromJson(json);
        }
      case Backend.starting:
        {
          return StartingBackendStatus.fromJson(json);
        }
      case Backend.running:
        {
          return RunningBackendStatus.fromJson(json);
        }
      case Backend.completed:
        {
          return CompletedBackendStatus.fromJson(json);
        }
    }
  }
}

@JsonSerializable()
class QueuedBackendStatus extends BackendStatus {
  final int rank;
  @JsonKey(name: 'queue_size')
  final int queueSize;
  @JsonKey(name: 'rank_eta')
  final double rankEta;

  QueuedBackendStatus(super.backend,
      {required this.rank, required this.queueSize, required this.rankEta});

  factory QueuedBackendStatus.fromJson(Map<String, dynamic> json) =>
      _$QueuedBackendStatusFromJson(json);
}

@JsonSerializable()
class StartingBackendStatus extends BackendStatus {
  StartingBackendStatus(super.backend);

  factory StartingBackendStatus.fromJson(Map<String, dynamic> json) =>
      _$StartingBackendStatusFromJson(json);
}

enum RunningDesc {
  @JsonValue('Loading audio file...')
  loadingAudio,
  @JsonValue('Pre-processing audio file...')
  preProcessing,
  @JsonValue('Transcribing...')
  transcribing,
}

@JsonSerializable()
class RunningBackendStatus extends BackendStatus {
  @JsonKey(readValue: _readDesc)
  final RunningDesc desc;
  @JsonKey(readValue: _readIndex)
  final int? index;
  @JsonKey(readValue: _readLength)
  final int? length;

  RunningBackendStatus(super.backend,
      {required this.desc, this.index, this.length});

  factory RunningBackendStatus.fromJson(Map<String, dynamic> json) =>
      _$RunningBackendStatusFromJson(json);
}

/// The second parameter is the key which we don't need
String _readDesc(dynamic json, _) {
  return json['progress_data'][0]['desc'];
}

int? _readIndex(dynamic json, _) {
  return json['progress_data'][0]['index'];
}

int? _readLength(dynamic json, _) {
  return json['progress_data'][0]['length'];
}

@JsonSerializable()
class CompletedBackendStatus extends BackendStatus {
  @JsonKey(readValue: readOutput)
  final String output;

  CompletedBackendStatus(super.backend, {required this.output});

  factory CompletedBackendStatus.fromJson(Map<String, dynamic> json) =>
      _$CompletedBackendStatusFromJson(json);
}

String readOutput(dynamic json, _) {
  return json['output']['data'][1];
}
