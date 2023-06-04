// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'segment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Segment _$SegmentFromJson(Map<String, dynamic> json) => Segment(
      id: json['id'] as int,
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
      text: json['text'] as String,
    );

Map<String, dynamic> _$SegmentToJson(Segment instance) => <String, dynamic>{
      'id': instance.id,
      'start': instance.start,
      'end': instance.end,
      'text': instance.text,
    };
