import 'package:json_annotation/json_annotation.dart';

part 'segment.g.dart';

@JsonSerializable()
class Segment {
  final int id;
  final double start;
  final double end;
  final String text;

  Segment(
      {required this.id,
      required this.start,
      required this.end,
      required this.text});


  @override
  String toString() {
    return 'Segment{id: $id, start: $start, end: $end, text: $text}';
  }

  factory Segment.fromJson(Map<String, dynamic> json) => _$SegmentFromJson(json);
  Map<String, dynamic> toJson( instance) => _$SegmentToJson(this);
}
