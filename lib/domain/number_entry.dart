import 'package:freezed_annotation/freezed_annotation.dart';

part 'number_entry.freezed.dart';

@Freezed()
class NumberEntry with _$NumberEntry {
  const factory NumberEntry({
    required int index,
    required String number,
    required String color,
    required String description,
  }) = _NumberEntry;
}


@Freezed()
class PartEntry with _$PartEntry {
  const factory PartEntry({
    required int offset,
    required String number,
  }) = _PartEntry;
}