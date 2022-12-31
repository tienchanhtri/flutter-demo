import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:numberteller/domain/number_processor.dart';
import 'package:numberteller/util.dart';

import 'async.dart';
import 'data/number_teller/number_config.dart';
import 'domain/number_entry.dart';

extension NumberTellerNavigator on BuildContext {
  void openNumberTeller() {
    Navigator.of(this).push(MaterialPageRoute(builder: (context) {
      return const NumberTellerPage();
    }));
  }
}

enum TellMode {
  full,
  single,
  double,
}

class NumberTellerPage extends StatefulWidget {
  const NumberTellerPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NumberTellerState();
  }
}

Future<List<NumberConfig>> loadConfig() async {
  final jsonConfig = await rootBundle.loadString('assets/number_config.json');
  final jsonList = await compute((_) async {
    return json.decode(jsonConfig) as Iterable;
  }, 0);
  return List<NumberConfig>.from(jsonList.map((model) {
    return NumberConfig.fromJson(model);
  }));
}

Future<List<NumberEntry>> loadTellList(
  List<NumberConfig> config,
  TellMode mode,
  String number,
) {
  return compute((_) {
    blocking(1000);
    switch (mode) {
      case TellMode.full:
        return tellFreeForm(config, number);
      case TellMode.single:
        return tellSingle(config, number);
      case TellMode.double:
        return tellDouble(config, number);
    }
  }, 0);
}

class _NumberTellerState extends State<NumberTellerPage> {
  TellMode tellMode = TellMode.full;
  int debounceMs = 300;
  String number = "";
  StreamSubscription? loadTellResultJob;
  CancelableOperation<List<NumberEntry>>? debounceJob;
  Async<List<NumberConfig>> configRequest = Uninitialized;
  Async<List<NumberEntry>> entriesRequest = Uninitialized;
  final queryController = TextEditingController();
  final indicatorColors = {
    "-1": const Color(0xffef9a9a),
    "0": const Color(0xfffdd835),
    "1": const Color(0xffa5d6a7),
  };
  final indicatorDefaultColor = const Color(0xffbdbdbd);

  final activeIndicatorColors = {
    "-1": const Color(0xffba6b6c),
    "0": const Color(0xffc6a700),
    "1": const Color(0xff75a478),
  };
  final activeIndicatorDefaultColor = const Color(0xff8d8d8d);

  int selectedIndex = -1;

  final entryColor = Color(0xfff5f5f5);
  final activeEntryColor = Color(0xffeeeeee);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      WidgetsFlutterBinding.ensureInitialized();
      loadConfig().execute((async) {
        setState(() {
          configRequest = async;
        });
        loadTellResult(true);
        if (async is Fail) {
          throw (async as Fail).error;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    loadTellResultJob?.cancel();
    debounceJob?.cancel();
  }

  void loadTellResult(bool immediately) {
    final config = configRequest();
    if (config == null) {
      return;
    }
    final numberInput = number;
    if (numberInput.isEmpty) {
      setState(() {
        entriesRequest = Uninitialized;
      });
      return;
    }
    setState(() {
      selectedIndex = -1;
    });
    var canceled = false;
    final mode = tellMode;
    loadTellResultJob?.cancel();
    debounceJob?.cancel();
    debounceJob = CancelableOperation.fromFuture(() async {
      if (canceled) {
        throw StateError("Canceled");
      }
      if (!immediately) {
        await Future.delayed(Duration(milliseconds: debounceMs));
      }
      if (canceled) {
        throw StateError("Canceled");
      }
      return loadTellList(config, mode, numberInput);
    }(), onCancel: () {
      canceled = true;
    });
    loadTellResultJob = debounceJob?.value.execute((async) {
      setState(() {
        entriesRequest = async;
      });
    }, retainValue: entriesRequest());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Number teller"),
        ),
      ),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 40),
          child: IntrinsicWidth(
            child: TextField(
              autofocus: true,
              keyboardType: TextInputType.phone,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
              ),
              maxLines: 1,
              decoration: const InputDecoration(
                  hintStyle: TextStyle(color: Colors.black12),
                  hintText: "012345678"),
              onChanged: (value) {
                setState(() {
                  number = value;
                  loadTellResult(false);
                });
              },
              onSubmitted: (value) {
                setState(() {
                  number = value;
                  loadTellResult(true);
                });
              },
              controller: queryController,
            ),
          ),
        ),
      ),
      Expanded(child: buildTellListContainer(context))
    ]);
  }

  Widget buildTellListContainer(BuildContext context) {
    final tellList = entriesRequest()?.mapIndexed((index, numberEntry) {
      final isActive = index == selectedIndex;
      final colorCode = numberEntry.color;
      Color indicatorColor;
      Color bodyColor;
      if (isActive) {
        indicatorColor =
            activeIndicatorColors[colorCode] ?? activeIndicatorDefaultColor;
        bodyColor = activeEntryColor;
      } else {
        indicatorColor = indicatorColors[colorCode] ?? indicatorDefaultColor;
        bodyColor = entryColor;
      }
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 8,
            color: indicatorColor,
          ),
          Container(
            color: bodyColor,
            padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),
            child: Column(
              children: numberEntry.number
                  .split("")
                  .map((e) => Text(
                        e,
                        style: const TextStyle(fontSize: 18),
                      ))
                  .toList(),
            ),
          ),
          Expanded(
              child: Container(
                  color: bodyColor,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    numberEntry.description,
                  )))
        ],
      );
      return GestureDetector(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        behavior: HitTestBehavior.translucent,
        child: IntrinsicHeight(
          child: row,
        ),
      );
    });
    final loadingWidget = <Widget>[];
    if (entriesRequest is Loading) {
      loadingWidget.add(const Align(
          alignment: Alignment.topCenter, child: RefreshProgressIndicator()));
    }

    return Stack(
      children: [
        Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            child: ListView(children: [...?tellList])),
        ...loadingWidget,
      ],
    );
  }
}
