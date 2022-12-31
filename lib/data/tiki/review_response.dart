import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_response.freezed.dart';

part 'review_response.g.dart';

@Freezed()
class ReviewDetail with _$ReviewDetail {
  const factory ReviewDetail({
    required int id,
    List<ReviewImage>? images,
  }) = _ReviewDetail;

  factory ReviewDetail.fromJson(Map<String, dynamic> json) =>
      _$ReviewDetailFromJson(json);
}

@Freezed()
class ReviewImage with _$ReviewImage {
  const factory ReviewImage({
    @JsonKey(name: "full_path") required String fullPath,
  }) = _ReviewImage;

  factory ReviewImage.fromJson(Map<String, dynamic> json) =>
      _$ReviewImageFromJson(json);
}
