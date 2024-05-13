import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  late BehaviorSubject<List<int>> _dataSubject;
  late ScrollController _scrollController;
  final int _perPage = 10;
  int _counter = 0;
  bool _scrollDown = true;

  @override
  void initState() {
    super.initState();
    _dataSubject = BehaviorSubject<List<int>>();
    _scrollController = ScrollController()..addListener(_scrollListener);
    loadData();
  }

  @override
  void dispose() {
    _dataSubject.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    // Simulating loading data asynchronously
    Future.delayed(const Duration(milliseconds: 500), () {
      final newData = List.generate(_perPage, (index) => _counter * _perPage + index + 1);
      if (_scrollDown) {
        _dataSubject.add(newData);
        _counter++; // Increment the counter if scrolling down
      } else if (_counter > 1) { // Prevent scroller from scrolling past the top
        _counter--; // Decrement the counter if scrolling up
        final oldData = List.generate(_perPage, (index) => _counter * _perPage - index);
        _dataSubject.add(oldData.reversed.toList());
      }
    });
  }

  void _scrollListener() {
  if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
      !_scrollController.position.outOfRange) {
    // Reached the end, load more data
    _scrollDown = true;
    loadData();
    Future.delayed(const Duration(milliseconds: 500), () { // Delay to match the delay of loading data
      _scrollController.jumpTo(_scrollController.position.minScrollExtent + 2.5);  // Make sure the focus is on the top new item
    });
  } else if ((_scrollController.offset <= _scrollController.position.minScrollExtent &&
      !_scrollController.position.outOfRange)){
    // Scrolled to the top, load previous data
    _scrollDown = false;
    loadData();
    if (_counter > 1) {
      Future.delayed(const Duration(milliseconds: 500), () { // Delay to match the delay of loading data
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent - 2.5); // Make sure the focus doesn't jump to the top old item
      });
    }
  }

}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scroll Example'),
      ),
      body: StreamBuilder<List<int>>(
        stream: _dataSubject.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = snapshot.data!;
            return ListView.builder(
              controller: _scrollController,
              itemCount: data.length + 1, // +1 for loading indicator
              itemBuilder: (context, index) {
                if (index < data.length) {
                  return ListTile(
                    title: Text('Item ${data[index]}'),
                    minVerticalPadding: 50.0, // Arbitrary number to test the actual scrolling behavior
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
