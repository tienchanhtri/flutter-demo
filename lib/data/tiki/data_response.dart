import 'package:freezed_annotation/freezed_annotation.dart';

part 'data_response.freezed.dart';

part 'data_response.g.dart';

@Freezed(genericArgumentFactories: true)
class DataResponse<T> with _$DataResponse<T> {
  const factory DataResponse({
    required T data,
  }) = _DataResponse;

  factory DataResponse.fromJson(
          Map<String, dynamic> json, T Function(Object?) fromJsonT) =>
      _$DataResponseFromJson(json, fromJsonT);
}
