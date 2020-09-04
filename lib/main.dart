import 'package:flutter/material.dart';
import 'package:flutter_create_stateless/counter_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChangeNotifierProvider(
        create: (context) => CounterState(),
        child: MyHomePage(title: 'Stateless Flutter Demo'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final counterState = Provider.of<CounterState>(context);
    // final _counter = counterState.value;
    // void _incrementCounter() => counterState.increment();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   'You have pushed the button this many times:',
            // ),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            Text(
              counterState.hasError
                  ? ''
                  : counterState.isWaiting
                      ? 'Please wait...'
                      : 'You have pushed the button this many times:',
            ),
            counterState.hasError
                ? Text("Oops, something's wrong!")
                : counterState.isWaiting
                    ? CircularProgressIndicator()
                    : Text(
                        '${counterState.value}',
                        style: Theme.of(context).textTheme.headline4,
                      ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            child: Icon(Icons.undo),
            // colors idicate when the button is inactive (i.e. when
            // counterState is waiting)
            backgroundColor: counterState.isWaiting
                ? Theme.of(context).buttonColor
                : Theme.of(context).floatingActionButtonTheme.backgroundColor,
            // the button action is disabled when counterState is waiting
            onPressed: counterState.isWaiting ? null : counterState.reset,
          ),
          FloatingActionButton(
            child: Icon(Icons.add),
            // colors indicate when the button is inactive (i.e. when
            // counterState is waiting)
            backgroundColor: (counterState.isWaiting || counterState.hasError)
                ? Theme.of(context).buttonColor
                : Theme.of(context).floatingActionButtonTheme.backgroundColor,
            // the button action is disabled when counterState is waiting
            onPressed: (counterState.isWaiting || counterState.hasError)
                ? null
                : counterState.increment,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
