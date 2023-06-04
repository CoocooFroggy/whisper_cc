import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Video {
  final String link;
  final String captions;

  Video({required this.link, required this.captions});
}