// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackendStatus _$BackendStatusFromJson(Map<String, dynamic> json) =>
    BackendStatus(
      $enumDecode(_$BackendEnumMap, json['backend']),
    );

Map<String, dynamic> _$BackendStatusToJson(BackendStatus instance) =>
    <String, dynamic>{
      'backend': _$BackendEnumMap[instance.backend]!,
    };

const _$BackendEnumMap = {
  Backend.queued: 'estimation',
  Backend.starting: 'process_starts',
  Backend.running: 'progress',
  Backend.completed: 'process_completed',
};

QueuedBackendStatus _$QueuedBackendStatusFromJson(Map<String, dynamic> json) =>
    QueuedBackendStatus(
      $enumDecode(_$BackendEnumMap, json['backend']),
      rank: json['rank'] as int,
      queueSize: json['queue_size'] as int,
      rankEta: (json['rank_eta'] as num).toDouble(),
    );

Map<String, dynamic> _$QueuedBackendStatusToJson(
        QueuedBackendStatus instance) =>
    <String, dynamic>{
      'backend': _$BackendEnumMap[instance.backend]!,
      'rank': instance.rank,
      'queue_size': instance.queueSize,
      'rank_eta': instance.rankEta,
    };

RunningBackendStatus _$RunningBackendStatusFromJson(
        Map<String, dynamic> json) =>
    RunningBackendStatus(
      $enumDecode(_$BackendEnumMap, json['backend']),
      progressData: (json['progress_data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$RunningBackendStatusToJson(
        RunningBackendStatus instance) =>
    <String, dynamic>{
      'backend': _$BackendEnumMap[instance.backend]!,
      'progress_data': instance.progressData,
    };

CompletedBackendStatus _$CompletedBackendStatusFromJson(
        Map<String, dynamic> json) =>
    CompletedBackendStatus(
      $enumDecode(_$BackendEnumMap, json['backend']),
      output: outputFromJson(json['output']),
    );

Map<String, dynamic> _$CompletedBackendStatusToJson(
        CompletedBackendStatus instance) =>
    <String, dynamic>{
      'backend': _$BackendEnumMap[instance.backend]!,
      'output': instance.output,
    };
