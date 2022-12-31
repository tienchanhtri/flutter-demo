// Import the test package and Counter class

import 'package:flutter_test/flutter_test.dart';
import 'package:numberteller/data/number_teller/number_config.dart';
import 'package:numberteller/domain/number_entry.dart';
import 'package:numberteller/domain/number_processor.dart';

void main() {
  final defaultConfig = [
    ...Iterable<int>.generate(100),
    111,
    444,
    1111,
    23456,
  ].map((number) {
    return NumberConfig(
        color: "${number}_c", number: "$number", description: "${number}_d");
  }).toList();


  List<NumberEntry> createExpected(
      String expected,
  ) {
    int index = 0;
    return expected.split(" ").map((number) {
      int numberIndex = index;
      index += number.length;
      if (number.contains("x")) {
        return NumberEntry(
            index: numberIndex,
            color: "",
            number: number,
            description: "");
      } else {
        return NumberEntry(
            index: numberIndex,
            color: "${number}_c",
            number: number,
            description: "${number}_d");
      }
    }).toList();
  }

  void checkFreeForm(
      String number,
      String expected,
      {List<NumberConfig>? config}
  ) {
    final actual = tellFreeForm(config ?? defaultConfig, number);
    final expectedResult = createExpected(expected);
    expect(actual, expectedResult);
  }

  void checkSingle(
      String number,
      String expected,
      {List<NumberConfig>? config}
  ) {
    final actual = tellSingle(config ?? defaultConfig, number);
    final expectedResult = createExpected(expected);
    expect(actual, expectedResult);
  }

  void checkDouble(
      String number,
      String expected,
      {List<NumberConfig>? config}
      ) {
    final actual = tellDouble(config ?? defaultConfig, number);
    final expectedResult = createExpected(expected);
    expect(actual, expectedResult);
  }

  test('free form 4', () {
    const number = "09154311111";
    const expected = "0 91 54 3 1111 1";
    checkFreeForm(number, expected);
  });

  test('free form 3', () {
    const number = "0914440300";
    const expected = "0 91 444 0 30 0";
    checkFreeForm(number, expected);
  });

  test('free form 2', () {
    const number = "987654321";
    const expected = "98 76 54 32 1";
    checkFreeForm(number, expected);
  });

  test('free form 1', () {
    const number = "123456789";
    const expected = "1 2 3 4 5 6 7 8 9";
    final config = defaultConfig.where((element) {
      return element.number.length == 1;
    }).toList();
    checkFreeForm(number, expected, config: config);
  });

  test('free form missing config 1', () {
    const number = "0914440300";
    const expected = "x 91 444 x 30 x";
    final config = defaultConfig.where((element) {
      return element.number != "0";
    }).toList();
    checkFreeForm(number, expected, config: config);
  });

  test('free form missing config 2', () {
    const number = "091440300";
    const expected = "0 91 xx 0 30 0";
    final config = defaultConfig.where((element) {
      return !element.number.contains("4");
    }).toList();
    checkFreeForm(number, expected, config: config);
  });

  test('free form missing config 3', () {
    const number = "0914440300";
    const expected = "0 91 xxx 0 30 0";
    final config = defaultConfig.where((element) {
      return !element.number.contains("4");
    }).toList();
    checkFreeForm(number, expected, config: config);
  });

  test('free form missing config 4', () {
    const number = "09144440300";
    const expected = "0 91 xxxx 0 30 0";
    final config = defaultConfig.where((element) {
      return !element.number.contains("4");
    }).toList();
    checkFreeForm(number, expected, config: config);
  });


  test('single 1', () {
    const number = "09144440300";
    const expected = "0 9 1 4 4 4 4 0 3 0 0";
    checkSingle(number, expected);
  });

  test('single 2', () {
    const number = "1234567890";
    const expected = "1 2 3 4 5 6 7 8 9 0";
    checkSingle(number, expected);
  });

  test('single missing config', () {
    const number = "1234567890";
    const expected = "1 2 3 x 5 6 7 8 9 0";
    final config = defaultConfig.where((element) {
      return !element.number.contains("4");
    }).toList();
    checkSingle(number, expected, config: config);
  });

  test('double 1', () {
    const number = "01234567891";
    final actual = tellDouble(defaultConfig, number);
    const expected = [
      NumberEntry(index: 0, number: "01", color: "1_c", description: "1_d"),
      NumberEntry(index: 1, number: "12", color: "12_c", description: "12_d"),
      NumberEntry(index: 2, number: "23", color: "23_c", description: "23_d"),
      NumberEntry(index: 3, number: "34", color: "34_c", description: "34_d"),
      NumberEntry(index: 4, number: "45", color: "45_c", description: "45_d"),
      NumberEntry(index: 5, number: "56", color: "56_c", description: "56_d"),
      NumberEntry(index: 6, number: "67", color: "67_c", description: "67_d"),
      NumberEntry(index: 7, number: "78", color: "78_c", description: "78_d"),
      NumberEntry(index: 8, number: "89", color: "89_c", description: "89_d"),
      NumberEntry(index: 9, number: "91", color: "91_c", description: "91_d"),
      NumberEntry(index: 10, number: "1", color: "1_c", description: "1_d")
    ];
    expect(actual, expected);
  });

  test('double 2', () {
    const number = "4440300";
    final actual = tellDouble(defaultConfig, number);
    const expected = [
      NumberEntry(index: 0, number: "44", color: "44_c", description: "44_d"),
      NumberEntry(index: 1, number: "44", color: "44_c", description: "44_d"),
      NumberEntry(index: 2, number: "40", color: "40_c", description: "40_d"),
      NumberEntry(index: 3, number: "03", color: "3_c", description: "3_d"),
      NumberEntry(index: 4, number: "30", color: "30_c", description: "30_d"),
      NumberEntry(index: 5, number: "xx", color: "", description: ""),
      NumberEntry(index: 6, number: "0", color: "0_c", description: "0_d"),
    ];
    expect(actual, expected);
  });
}
