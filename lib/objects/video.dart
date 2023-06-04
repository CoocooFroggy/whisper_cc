import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class CaptionedVideo {
  final String link;
  final String captions;

  CaptionedVideo({required this.link, required this.captions});
}