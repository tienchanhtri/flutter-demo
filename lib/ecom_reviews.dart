import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:numberteller/data/tiki/tiki_service.dart';

import 'async.dart';
import 'data/tiki/data_response.dart';
import 'data/tiki/review_response.dart';

extension EcomReviewNavigator on BuildContext {
  void openEcomReview(String productId) {
    Navigator.of(this).push(MaterialPageRoute(builder: (context) {
      return EcomReviewPage(productId: productId);
    }));
  }
}

class EcomReviewPage extends StatefulWidget {
  final String productId;
  final String? spid;

  const EcomReviewPage({super.key, required this.productId, this.spid});

  @override
  State<StatefulWidget> createState() {
    return _EcomReviewState();
  }
}

class _EcomReviewState extends State<EcomReviewPage> {
  StreamSubscription? getReviewsJob;
  Async<List<ReviewImage>> reviewsRequest = Uninitialized;
  final colCount = 10;
  final pageCount = 30;

  @override
  void initState() {
    super.initState();
    reload();
  }


  void reload() {
    getReviewsJob?.cancel();
    getReviewsJob = () async {
      final requests = List<Future<List<ReviewImage>>>.generate(pageCount, (i) {
        return tikiService.fetchReviews(productId: widget.productId, page: i)
        .then((value) => value.data.expand((element) {
          return [...?element.images];
        }).toList());
      }
      );
      final images = <ReviewImage>[];
      for (final request in requests) {
        images.addAll(await request);
      }
      return images;
    }()
    .execute((async) {
      setState(() {
        reviewsRequest = async;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Reviews for ${widget.productId}"),
        ),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    if (reviewsRequest is Loading) {
      return const Center(
        child: SizedBox(
            height: 48,
            width: 48,
            child: CircularProgressIndicator()
        ),
      );
    }
    final images = [...?reviewsRequest()];
    if (images.isEmpty) {
      return const Text("Empty");
    }
    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: colCount,
      // Generate 100 widgets that display their index in the List.
      children: List.generate(images.length, (index) {
        return Center(
          child: CachedNetworkImage(
            imageUrl: images[index].fullPath,
            imageBuilder: (context, imageProvider) => Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: imageProvider, fit: BoxFit.cover),
              ),
            ),
            placeholder: (context, url) {
              return Container(
                color: Colors.grey,
              );
            },
            errorWidget: (context, url, error) {
              return const Icon(Icons.error);
            },
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
          ),
        );
      }),
    );
  }
}
