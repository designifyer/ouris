import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async'; // for TimeoutException

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Flutter Stateful Clicker Counter';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _response = 'No response yet';

  // Function to connect to the scale and request data
  Future<void> requestData() async {
    final commandChars = {
      'CR': int.parse('0D', radix: 16),
      'W': int.parse('57', radix: 16),
      'S': int.parse('53', radix: 16),
      'Z': int.parse('5A', radix: 16),
      'LF': int.parse('0A', radix: 16),
      'ETX': int.parse('03', radix: 16),
      'Q': int.parse('3F', radix: 16),
    };

    final commands = {
      'weight': Uint8List.fromList([commandChars['W']!, commandChars['CR']!]),
      'status': Uint8List.fromList([commandChars['S']!, commandChars['CR']!]),
      'zero': Uint8List.fromList([commandChars['Z']!, commandChars['CR']!]),
    };

    try {
      final Future<Socket> socketFuture = Socket.connect('10.10.100.254', 8899);

      Socket socket = await socketFuture.timeout(
        Duration(seconds: 4),
        onTimeout: () {
          print('Socket connection timed out');
          throw TimeoutException('Socket connection timed out');
        },
      );

      print('Connected to scale');
      socket.add(commands['weight']!);
      print('Command Sent');

      socket.listen(
        (Uint8List data) {
          final String response = ascii.decode(data);
          print('Data received: $data');
          print('Response is: $response');

          setState(() {
            _response = response;
          });
        },
        onError: (error) {
          print('Error: $error');
        },
        onDone: () {
          print('Socket is closed');
        },
      );
    } catch (e) {
      print("Error: $e");
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Click Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 25),
            ),
            ElevatedButton(
              onPressed: requestData,
              child: const Text('Request Data'),
            ),
            Text(
              'Response: $_response',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
