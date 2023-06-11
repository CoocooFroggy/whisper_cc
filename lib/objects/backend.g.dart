// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BackendStatus _$BackendStatusFromJson(Map<String, dynamic> json) =>
    BackendStatus(
      $enumDecode(_$BackendEnumMap, json['msg']),
    );

Map<String, dynamic> _$BackendStatusToJson(BackendStatus instance) =>
    <String, dynamic>{
      'msg': _$BackendEnumMap[instance.backend]!,
    };

const _$BackendEnumMap = {
  Backend.queued: 'estimation',
  Backend.starting: 'process_starts',
  Backend.running: 'progress',
  Backend.completed: 'process_completed',
};

QueuedBackendStatus _$QueuedBackendStatusFromJson(Map<String, dynamic> json) =>
    QueuedBackendStatus(
      $enumDecode(_$BackendEnumMap, json['msg']),
      rank: json['rank'] as int,
      queueSize: json['queue_size'] as int,
      rankEta: (json['rank_eta'] as num).toDouble(),
    );

Map<String, dynamic> _$QueuedBackendStatusToJson(
        QueuedBackendStatus instance) =>
    <String, dynamic>{
      'msg': _$BackendEnumMap[instance.backend]!,
      'rank': instance.rank,
      'queue_size': instance.queueSize,
      'rank_eta': instance.rankEta,
    };

StartingBackendStatus _$StartingBackendStatusFromJson(
        Map<String, dynamic> json) =>
    StartingBackendStatus(
      $enumDecode(_$BackendEnumMap, json['msg']),
    );

Map<String, dynamic> _$StartingBackendStatusToJson(
        StartingBackendStatus instance) =>
    <String, dynamic>{
      'msg': _$BackendEnumMap[instance.backend]!,
    };

RunningBackendStatus _$RunningBackendStatusFromJson(
        Map<String, dynamic> json) =>
    RunningBackendStatus(
      $enumDecode(_$BackendEnumMap, json['msg']),
      progressData: (json['progress_data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$RunningBackendStatusToJson(
        RunningBackendStatus instance) =>
    <String, dynamic>{
      'msg': _$BackendEnumMap[instance.backend]!,
      'progress_data': instance.progressData,
    };

CompletedBackendStatus _$CompletedBackendStatusFromJson(
        Map<String, dynamic> json) =>
    CompletedBackendStatus(
      $enumDecode(_$BackendEnumMap, json['msg']),
      output: outputFromJson(json['output']),
    );

Map<String, dynamic> _$CompletedBackendStatusToJson(
        CompletedBackendStatus instance) =>
    <String, dynamic>{
      'msg': _$BackendEnumMap[instance.backend]!,
      'output': instance.output,
    };
