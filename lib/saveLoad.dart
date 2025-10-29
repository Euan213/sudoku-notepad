import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sudoku_notepad/saveData.dart';


abstract class saveLoad
{

  static const NEW_BOARD = -1;

  static Future<String> get _localPath async 
  {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _file async 
  {
  final path = await _localPath;
  return File('$path/saves.json'); 
  }

  static Future<String> get asString async 
  {
    File file = await _file;
    return file.readAsString();
  }

  static Future<Map<String, dynamic>> getSaves() async 
  {
    String content = await asString;
    if (content == '')
    {
      print("empty file detected");
      return {"next ID":0, "saves": {}};
    }
    Map<String, dynamic> saves = jsonDecode(content);
    return saves;
  }

  static String toJson(Map<String, dynamic> object)
  {
    return jsonEncode(object, 
      toEncodable: (object) => object is saveData
      ? object.toJson()
      : throw UnsupportedError("oopsies this isnt json encodable: $object")
    );
  }

  static Future<File> writeInitData() async //change
  {
    final file = await _file;
    return file.writeAsString('|1|0.0..987.0.0,0.0.654..0.0,0.0...1.0,0.2...0.1,0.0...0.1,0.0...0.1,0.0...0.2,0.0...0.2,0.0...0.2,0.0...0.0,0.0...0.0,0.0...0.0,0.0...0.1,0.0...0.1,0.0...0.1,0.0...0.2,0.0...0.2,0.0...0.2,0.0...0.0,0.0...0.0,0.0...0.0,0.0...0.1,0.0...0.1,0.0...0.1,0.0...0.2,0.0...0.2,0.0...0.2,0.0...0.3,0.0...0.3,0.0...0.3,0.0...0.4,0.0...0.4,0.0...0.4,0.0...0.5,0.0...0.5,0.0...0.5,0.0...0.3,0.0...0.3,0.0...0.3,0.0...0.4,0.0...0.4,0.0...0.4,0.0...0.5,0.0...0.5,0.0...0.5,0.0...0.3,0.0...0.3,0.0...0.3,0.0...0.4,0.0...0.4,0.0...0.4,0.0...0.5,0.0...0.5,0.0...0.5,0.0...0.6,0.0...0.6,0.0...0.7,1.5...2.6,1.5...2.7,1.5...2.7,0.0...0.8,0.0...0.8,0.0...0.8,0.0...0.6,0.0...0.6,0.0...0.7,1.5...2.6,1.5...2.7,1.5...2.7,0.0...0.8,0.0...0.8,0.0...0.8,0.0...0.6,0.0...0.6,0.0...0.6,1.5...2.7,1.5...2.7,1.5...2.7,0.0...0.8,0.0...0.8,0.0...0.8|PuzzleNAME\n');
    //                        'whats in this section is the list of constraints|here is the board mode|here is a list of cells of the board|puzzle name'
    //               each cell has 6 points isFixed.num.PencilCenterVals.pencilCornerVals.colourID.boxId
    //                                      0 or 1 .0-9.strings of up to 1 of each 1-9   .0-9     .0-8
    // return file.writeAsString('');
  }

  static Future<File> writeToFile(FileMode mode, String str) async
  {
    final file = await _file;
    return file.writeAsString(mode:mode, str);
  }

  static Future<int> saveBoard(int ID, Map<String, dynamic> board) async 
  {
    Map<String, dynamic> gameSaves = await getSaves();
    String jsonString = '';
    int newID = gameSaves["next ID"];
    if (ID == NEW_BOARD)
    {
      gameSaves["next ID"]++;
      gameSaves["saves"]["$newID"] = board;

    } else
    {
      gameSaves["saves"]["$ID"] = board;
    }
    jsonString = toJson(gameSaves);
    writeToFile(FileMode.write, jsonString);
    
    return ID==-1
    ? newID
    :ID;
  }

  static Future<void> deleteBoard(int ID) async
  {
    Map<String, dynamic> gameSaves = await getSaves();

    gameSaves["saves"].remove(ID.toString());
    String jsonString = toJson(gameSaves);

    writeToFile(FileMode.write, jsonString);
  }
}