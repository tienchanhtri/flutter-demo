import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:numberteller/data/tiki/data_response.dart';
import 'package:numberteller/data/tiki/product.dart';
import 'package:numberteller/data/tiki/tiki_service.dart';
import 'package:numberteller/ecom_reviews.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'async.dart';

Future<DataResponse<List<Product>>> fetchProduct({
  int page = 0,
  int limit = 100,
  String? query,
}) async {
  return compute((_) async {
    final result = await tikiService.products(
      query: query,
      page: page,
      limit: limit,
    );
    return result;
  }, 0);
}

void doComputeWork({int ms = 0}) {
  final stopwatch = Stopwatch()..start();
  while (ms > stopwatch.elapsedMilliseconds) {
    continue;
  }
}

class EcomListPage extends StatefulWidget {
  const EcomListPage({super.key, required this.query});

  final String query;

  @override
  State<EcomListPage> createState() => _EcomListState();
}

class _EcomListState extends State<EcomListPage> {
  GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey();
  late TextEditingController queryController;

  List<Product> products = [];
  Async<DataResponse<List<Product>>> productAsync = Uninitialized;
  StreamSubscription? loadProductJob;
  int pageSize = 20;
  int page = 0;
  bool isEndOfPage = false;
  late String query;

  @override
  void initState() {
    super.initState();
    query = widget.query;
    queryController = TextEditingController(text: widget.query);
    reloadExternal();
  }

  void reloadExternal() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      refreshIndicatorKey.currentState?.show();
    });
  }

  Future reload() {
    loadProductJob?.cancel();
    setState(() {
      page = 0;
      isEndOfPage = false;
      products = [];
    });
    return loadNextPage();
  }

  Future loadNextPage() {
    final loadPage = page + 1;
    if (productAsync is Loading || isEndOfPage) {
      return Future.value(null);
    }

    loadProductJob?.cancel();
    var newFetchJob = fetchProduct(
      page: loadPage,
      limit: pageSize,
      query: query,
    ).execute((async) {
      setState(() {
        productAsync = async;
        final newProduct = [...?productAsync.call()?.data];
        products = products + newProduct;
        if (productAsync is Success) {
          page = loadPage;
        }
        if (productAsync is Success && newProduct.length < pageSize) {
          isEndOfPage = true;
        }
      });
    });
    loadProductJob = newFetchJob;
    return newFetchJob.asFuture();
  }

  @override
  void dispose() {
    super.dispose();
    loadProductJob?.cancel();
    queryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Container(
            height: 40,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Center(
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: const Icon(
                      Icons.search,
                      color: Colors.black12,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: TextField(
                        decoration: const InputDecoration.collapsed(
                            hintText: 'search...'),
                        onSubmitted: (value) {
                          setState(() {
                            query = value;
                            reloadExternal();
                          });
                        },
                        controller: queryController,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        key: refreshIndicatorKey,
        onRefresh: reload,
        child: Container(
          color: Colors.black12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView(children: buildProducts(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildProducts(BuildContext context) {
    final widgets = <Widget>[];
    if (productAsync is Fail) {
      widgets.add(const Text("Error"));
    }

    if (productAsync is Success) {}
    final lastProductIndex = products.length - 1;
    final loadMoreFromIndex = lastProductIndex - pageSize;
    products.forEachIndexed((index, product) {
      final productWidget = Container(
        margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: VisibilityDetector(
          key: ValueKey("product_${product.id} ${product.thumbnailUrl}"),
          onVisibilityChanged: (info) {
            if (index > loadMoreFromIndex && info.visibleFraction >= 0.5) {
              loadNextPage();
            }
          },
          child: Card(
            elevation: 0,
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 160,
                  width: 160,
                  child: CachedNetworkImage(
                    imageUrl: product.thumbnailUrl,
                    placeholder: (context, url) {
                      return Container(
                        color: Colors.grey,
                      );
                    },
                    errorWidget: (context, url, error) {
                      return const Icon(Icons.error);
                    },
                  ),
                ),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${product.name} ${product.name}",
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      buildRatingRow(context, product),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      );

      widgets.add(GestureDetector(
        child: productWidget,
        onTap: () {
          context.openEcomReview(product.id.toString());
        },
        onLongPress: () {
          context.openEcomReview(product.id.toString());
        },
      ));
    });

    if (productAsync is Loading && page > 0) {
      widgets.add(Center(
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 16, 0, 48),
          width: 48,
          height: 48,
          child: const CircularProgressIndicator(),
        ),
      ));
    }

    return widgets;
  }

  Row buildRatingRow(BuildContext context, Product product) {
    var widgets = <Widget>[];
    var rating = product.ratingAverage ?? 0.0;
    if (rating > 0) {
      widgets.add(Text(
        "${rating.toStringAsFixed(1)} ⭐",
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ));
    }
    var quantitySole = product.quantitySold?.text;
    if (quantitySole != null) {
      if (widgets.isNotEmpty) {
        widgets.add(Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 1,
          height: 8,
          color: Colors.black12,
        ));
      }
      widgets.add(Text(
        quantitySole,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ));
    }
    return Row(
      children: widgets,
    );
  }
}
