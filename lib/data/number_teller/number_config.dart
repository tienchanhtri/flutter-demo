import 'package:freezed_annotation/freezed_annotation.dart';

part 'number_config.freezed.dart';

part 'number_config.g.dart';

@Freezed()
class NumberConfig with _$NumberConfig {
  const factory NumberConfig({
    required String color,
    required String number,
    required String description,
  }) = _NumberConfig;

  factory NumberConfig.fromJson(Map<String, dynamic> json) =>
      _$NumberConfigFromJson(json);
}