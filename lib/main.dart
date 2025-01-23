import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sudoku_notepad/board.dart';
import 'package:sudoku_notepad/saveLoad.dart';

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
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          surface: Color.fromARGB(255, 41, 64, 78),
          onSurface: const Color.fromARGB(255, 0, 0, 0),
          primary: Colors.black,
          onPrimary: const Color.fromARGB(255, 6, 58, 100),
          secondary: const Color.fromARGB(255, 124, 74, 0),
          onSecondary: Colors.amber,
          error: Colors.red,
          onError: Colors.black,
        ),
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
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: const Color.fromARGB(255, 6, 58, 100),
      //   automaticallyImplyLeading: false,
      //   title: Text('Home'),
      // ),
      body: Center(
        child: Column(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            Spacer(),
            Text('APP ICON HERE PROBALY'),
            Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Board(-1, [], false, '', 'New Puzzle'))),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.green
              ),
              child: SizedBox(
                height: 100,
                width: 70,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('New Puzzle', textAlign: TextAlign.center, textScaler: TextScaler.linear(1.5),),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => SavesPage())),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: Colors.green
              ),
              child: SizedBox(
                height: 100,
                width: 90,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('Saved Puzzles', textAlign: TextAlign.center, textScaler: TextScaler.linear(1.5),),
                ),
              ),
            ),
            Spacer(),

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
  @override
  void initState()
  {
    super.initState();
    SaveLoad.writeToFile(FileMode.append, '');
    // SaveLoad.writeInitData();
    // _numSaves;
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saves'),
      ),
      body: FutureBuilder<String>(
        future: SaveLoad.asString, 
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) 
        {
          switch (snapshot.connectionState) 
          {
            case ConnectionState.waiting || ConnectionState.active: 
              return Text('Loading your saves');
            default:
              List<String>? data = snapshot.data?.split('\n');
              if (snapshot.hasError)
              {
                return Text('Error: ${snapshot.error}');  
              }
              else
              {
                if (snapshot.data=='')
                {
                  return Text('Looks like you have no saves!');
                }
                return GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(5),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: data!.length-1,
                  itemBuilder: (context, index) 
                  {
                    List<String> boardData = data[index].split('|');
                    if (boardData.length!=4)
                    {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.black,
                          textStyle: TextStyle(fontWeight: FontWeight.bold,),
                        ),
                        onPressed: () => {
                          SaveLoad.deleteBoard(index).then((_) 
                          {
                            setState(() {});
                          }), 
                        },
                        child: Text('Delete corrupted save'));
                    }
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child:DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: Stack(
                            children:[
                              Container(alignment: Alignment.topCenter, child: Text(
                                boardData[3],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 42, 0, 228),)
                              )),
                              Container(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => Board(index, boardData[0]==''?[]:boardData[0].split('¦'), boardData[1]=='0'?false:true, boardData[2], boardData[3])
                                      )),
                                      icon: Icon(Icons.play_arrow, color: const Color.fromARGB(255, 0, 158, 5), size: 50,)
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                        showDialog<String>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text('Delete ${boardData[3]}?'),
                                            content: Text('Are you absolutely sure you want to kill ${boardData[3]}? Theres no going back.'),
                                            actions: [
                                              ElevatedButton(
                                                onPressed: () => {
                                                  Navigator.pop(context, 'Killed'),
                                                  SaveLoad.deleteBoard(index).then((_) 
                                                  {
                                                    setState(() {});
                                                  }), 
                                                },
                                                child: Text('YES KILL IT!'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(context, 'Cancel'), 
                                                child: Text('no.'),
                                              )
                                            ]),
                                        ),
                                      icon: Icon(Icons.delete, size: 35,)
                                    ),  
                                  ])
                              ),
                            ]),
                        ),
                      ),
                    );
                  });
              }
          }
        }
      ),
    );
  }
}
