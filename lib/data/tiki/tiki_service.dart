import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:numberteller/data/tiki/product.dart';
import 'package:numberteller/data/tiki/review_response.dart';
import 'package:retrofit/retrofit.dart';

import 'data_response.dart';

part 'tiki_service.g.dart';

@RestApi(baseUrl: "https://api.tiki.vn/v2")
abstract class TikiService {
  factory TikiService(Dio dio, {String baseUrl}) = _TikiService;

  @GET("/products")
  Future<DataResponse<List<Product>>> products({
    @Query("q") String? query,
    @Query("limit") int limit = 100,
    @Query("page") int page = 1,
  });

  @GET("/reviews")
  Future<DataResponse<List<ReviewDetail>>> reviews({
    @Query("product_id") required String productId,
    @Query("spid") String? spid,
    @Query("page") int page = 1,
  });
}

final dio = Dio();
final tikiService = TikiService(dio);


extension TikiServiceAsync on TikiService {
  Future<DataResponse<List<ReviewDetail>>> fetchReviews({
    required String productId,
    int page = 1,
  }) {
    return compute((_) {
      return reviews(productId: productId, page: page);
    }, null);
  }
}
