import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sudoku_notepad/board.dart';
import 'package:path_provider/path_provider.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text('Home'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Board())),
              child: Text('New Puzzle'),
            ),            
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SavesPage())),
              child: Text('Saves'),
            ),
          ],
        ),
      ),

    );
  }
}

class SavesPage extends StatefulWidget {
  const SavesPage({super.key});
  @override
  State<SavesPage> createState() => _SavesPageState();
}

class _SavesPageState extends State<SavesPage>
{
  Future<String> get _localPath async 
  {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _file async 
  {
  final path = await _localPath;
  return File('$path/saves.txt');
  }

  Future<List<String>> get _saves async
  {
    File file = await _file;
    // writeInitData();
    String content = await file.readAsString();
    if (content == '')
    {
      return [];
    }
    List<String> saves = content.split('\n');
    return saves;
  }

  Future<File> writeInitData() async 
  {
    final file = await _file;
    // return file.writeAsString('|0|0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0,0.0.0.0.0');
    return file.writeAsString('');

  }

  @override
  void initState()
  {
    super.initState();
    // writeInitData();
    // _numSaves;
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('Saves')),
      body: FutureBuilder<List<String>>(
        future: _saves, 
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot)
        {
          switch (snapshot.connectionState) 
          {
            case ConnectionState.waiting: 
              return Text('Loading your saves');
            default:
              if (snapshot.hasError)
              {
                return Text('Error: ${snapshot.error}');  
              }
              else
              {
                if (snapshot.data?.length==0)
                {
                  return Text('Looks like you have no saves!');
                }
                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) 
                  {
                    return Container(
                      color: Colors.blue,
                      child: Text('${snapshot.data?[index]}'),
                    );
                  },
                );
              }
          }
        }
      ),
    );
  }
}
