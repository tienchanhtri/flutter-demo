import 'dart:math';

import 'package:numberteller/data/number_teller/number_config.dart';
import 'package:numberteller/domain/number_entry.dart';

List<NumberEntry> tellFreeForm(List<NumberConfig> config, String number) {
  final result = <NumberEntry>[];
  final stack = <PartEntry>[];
  stack.add(PartEntry(offset: 0, number: number));
  whileLoop:
  while (stack.isNotEmpty) {
    final part = stack.removeLast();
    forLoop:
    for (NumberConfig config in config.reversed) {
      if (config.number.length > part.number.length) {
        continue forLoop;
      }
      final startIndex = part.number.indexOf(config.number);
      if (startIndex == -1) {
        continue forLoop;
      }
      result.add(
        NumberEntry(
            index: startIndex + part.offset,
            color: config.color,
            number: config.number,
            description: config.description
        )
      );
      if (part.number.length != config.number.length) {
        final endStartIndex = startIndex + config.number.length;
        final endEndIndex = part.number.length;
        if (endEndIndex > endStartIndex) {
          stack.add(
              PartEntry(
                  offset: part.offset + startIndex + config.number.length,
                  number: part.number.substring(
                      endStartIndex,
                      endEndIndex
                  )
              )
          );
        }

        if (startIndex > 0) {
          stack.add(
              PartEntry(
                  offset: part.offset,
                  number: part.number.substring(0, startIndex)
              )
          );
        }
      }
      continue whileLoop;
    }

    result.add(
      NumberEntry(
          index: part.offset,
          number: "x" * part.number.length,
          color: "",
          description: ""
      )
    );
  }
  result.sort((a, b) => a.index.compareTo(b.index));
  return result;
}

List<NumberEntry> tellSingle(List<NumberConfig> config, String number) {
  final Map<String, NumberConfig> singleConfig = {};
  for (NumberConfig c in config) {
    if (c.number.length == 1) {
      singleConfig[c.number] = c;
    }
  }
  final result = <NumberEntry>[];
  for(int i=0; i < number.length; i++) {
    final char = number[i];
    if (singleConfig.containsKey(char)) {
      final config = singleConfig[char]!;
      result.add(
          NumberEntry(
              index: i,
              number: char,
              color: config.color,
              description: config.description,
          )
      );
    } else {
      result.add(
          NumberEntry(
              index: i,
              number: "x",
              color: "",
              description: "",
          )
      );
    }
  }
  return result;
}

List<NumberEntry> tellDouble(List<NumberConfig> config, String number) {
  final Map<String, NumberConfig> doubleConfig = {};
  for (NumberConfig c in config) {
    if (c.number.isNotEmpty && c.number.length <= 2) {
      doubleConfig[c.number] = c;
      if (c.number.length == 1 && c.number != "0") {
        doubleConfig["0${c.number}"] = c;
      }
    }
  }
  final result = <NumberEntry>[];
  for(int i=0; i < number.length; i++) {
    final part = number.substring(i, min(i + 2, number.length));
    if (doubleConfig.containsKey(part)) {
      final config = doubleConfig[part]!;
      result.add(
          NumberEntry(
            index: i,
            number: part,
            color: config.color,
            description: config.description,
          )
      );
    } else {
      result.add(
          NumberEntry(
            index: i,
            number: "x" * part.length,
            color: "",
            description: "",
          )
      );
    }
  }
  return result;
}
