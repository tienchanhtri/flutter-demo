import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:numberteller/number_teller.dart';

import 'ecom_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          const EcomListPage(query: "iphone")));
                },
                child: const Text('Ecom list')),
            const SizedBox(
              width: 1,
              height: 8,
            ),
            ElevatedButton(
                onPressed: () {
                  context.openNumberTeller();
                },
                child: const Text('Number teller')),
          ],
        ),
      ),
    );
  }
}
