import 'dart:io';
import 'package:path_provider/path_provider.dart';


class SaveLoad
{
  SaveLoad._();

  static Future<String> get _localPath async 
  {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _file async 
  {
  final path = await _localPath;
  return File('$path/saves.txt');
  }

  static Future<String> get asString async 
  {
    File file = await _file;
    return file.readAsString();
  }

  static Future<List<String>> get saves async
  {
    String content = await asString;
    if (content == '')
    {
      return [];
    }
    List<String> saves = content.split('\n');
    return saves;
  }

  static Future<File> writeInitData() async 
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

  static Future<int> saveBoard(int index, String board) async
  {
    String content = await asString;
    List<String> saves = content.split('\n');
    if (index == -1)
    {
      writeToFile(FileMode.append, '$board\n');
      return saves.length-1; //returns length-1 because the length of saves changes when the file is updated, despite being defined above this happening.
    }
    try
    {
      saves[index] = board;
    }catch (e)
    {
      print(e);
      return index;
    }
    writeToFile(FileMode.write, '${saves.where((board) => board!='').join('\n')}\n');
    return index;
  }

  static Future<void> deleteBoard(int index) async
  {
    List<String> boards = await saves;

    boards.removeAt(index);
    String deleted = boards.join('\n');

    writeToFile(FileMode.write, deleted);
  }
}