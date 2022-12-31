import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

part 'product.g.dart';

@Freezed()
class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    @JsonKey(name: "thumbnail_url")
    required String thumbnailUrl,
    @JsonKey(name: "rating_average")
    double? ratingAverage,
    @JsonKey(name: "quantity_sold")
    QuantitySold? quantitySold,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

@Freezed()
class QuantitySold with _$QuantitySold {
  const factory QuantitySold({
    required String text,
  }) = _QuantitySold;

  factory QuantitySold.fromJson(Map<String, dynamic> json) =>
      _$QuantitySoldFromJson(json);
}
