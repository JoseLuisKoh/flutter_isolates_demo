import 'dart:isolate';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // provides a structure for the app (background, layout).
    return Scaffold(
      backgroundColor: Colors.white,
      //avoids rendering content under system UI elements.
      body: SafeArea(
        //Center and Column align and stack the widgets vertically.
        child: Center(
            child: Column(
          children: [
            Image.asset('assets/gifs/bouncing-ball.gif'),
            //Blocking UI task
            ElevatedButton(
              onPressed: () async {
                //Calls complexTask1, which performs a loop iterating 1 billion times.
                var total = await complexTask1();
                //Uses async/await to prevent UI from freezing.
                debugPrint('Result 1: $total');
              },
              child: const Text('Task 1'),
            ),
            //Isolate
            ElevatedButton(
              onPressed: () async {
                final receivePort = ReceivePort();
                //Uses a ReceivePort to receive the computation result asynchronously.
                await Isolate.spawn(complexTask2, receivePort.sendPort);
                receivePort.listen((total) {
                  debugPrint('Result 2: $total');
                });
                //Spawns an isolate to perform complexTask2.
              },
              child: const Text('Task 2'),
            ),
            //Isolate with parameters
            ElevatedButton(
              onPressed: () async {
                final receivePort = ReceivePort();
                await Isolate.spawn(
                    complexTask3,
                    //Demonstrates passing arguments to an isolate (iteration and sendPort).
                    //Computes the sum in a separate isolate, then sends the result back.
                    (iteration: 1000000000, sendPort: receivePort.sendPort));
                receivePort.listen((total) {
                  debugPrint('Result 3: $total');
                });
              },
              child: const Text('Task 3'),
            ),
          ],
        )),
      ),
    );
  }

  //Performs a loop to calculate the sum of the first billion numbers.
  //Executes asynchronously to prevent UI blocking.
  Future<double> complexTask1() async {
    var total = 0.0;
    for (var i = 0; i < 1000000000; i++) {
      total += i;
    }
    return total;
  }
}

//--End of HomePage--
//Runs the same computation as complexTask1, but in an isolate.
//Sends the result back using sendPort.

complexTask2(SendPort sendPort) {
  var total = 0.0;
  for (var i = 0; i < 1000000000; i++) {
    total += i;
  }
  sendPort.send(total);
}

//Accepts a parameterized argument for the number of iterations.
//Runs in an isolate and sends the computed result back.
complexTask3(({int iteration, SendPort sendPort}) data) {
  var total = 0.0;
  for (var i = 0; i < data.iteration; i++) {
    total += i;
  }
  data.sendPort.send(total);
}

//-- POJO --
