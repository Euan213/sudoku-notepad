import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku_notepad/board.dart';
import 'package:sudoku_notepad/saveLoad.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
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

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const NEW_BOARD = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          // spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>
          [
            Spacer(),
            Center(
              child: Image.asset('assets/Icon.png'),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => Board(initBoardId: NEW_BOARD, constraints:[], boardModePlay: false, board: [], name: 'New Puzzle'))),
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

class TempBoard 
{
  int ID;
  Map<String, dynamic> boardData;

  TempBoard(this.ID, this.boardData);
}

class _SavesPageState extends State<SavesPage>
{
  @override
  void initState()
  {
    super.initState();
    saveLoad.writeToFile(FileMode.append, '');
  }
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saves'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: saveLoad.getSaves(), 
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) 
        {
          var savesList = [];
          switch (snapshot.connectionState) 
          {
            case ConnectionState.waiting || ConnectionState.active: 
              return Text('Loading your saves');
            default:
              Map<dynamic, dynamic>? data = snapshot.data?["saves"];
              data?.forEach((k,v) => savesList.add(TempBoard(int.parse(k), v)));
              if (snapshot.hasError)
              {
                return Text('Error: ${snapshot.error}');  
              }
              else
              {
                if (savesList.isEmpty)
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
                  itemCount: savesList.length,
                  itemBuilder: (context, index) 
                  {
                    TempBoard temp = savesList[index];
                    if (temp.boardData.length!=4)
                    {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.black,
                          textStyle: TextStyle(fontWeight: FontWeight.bold,),
                        ),
                        onPressed: () => {
                          saveLoad.deleteBoard(temp.ID).then((_) 
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
                                temp.boardData["name"],
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
                                        builder: (context) => Board(initBoardId:temp.ID, constraints:temp.boardData["constraints"], boardModePlay: temp.boardData["playMode"], board: temp.boardData["board"], name: temp.boardData["name"],)
                                      )),
                                      icon: Icon(Icons.play_arrow, color: const Color.fromARGB(255, 0, 158, 5), size: 50,)
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                        showDialog<String>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: const Color.fromARGB(255, 199, 199, 199),
                                            title: Text('Delete ${temp.boardData["name"]}?'),
                                            content: Text('Are you absolutely sure you want to kill ${temp.boardData["name"]}? Theres no going back.'),
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 212, 212, 212)),
                                                onPressed: () => {
                                                  Navigator.pop(context, 'Killed'),
                                                  saveLoad.deleteBoard(temp.ID).then((_) 
                                                  {
                                                    setState(() {});
                                                  }), 
                                                },
                                                child: Text('YES KILL IT!'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 212, 212, 212)),
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
