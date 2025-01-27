import 'package:sudoku_notepad/hintType.dart';

class Hint
{
  HintType? sector;
  HintType type;

  List<int> cellIds;

  late int? sectorId;


  late String hintText;

  Hint(this.type, this.cellIds, this.sector);

  String get text
  {
    switch(type)
    {
      case HintType.mistake:
        return 'Oh dear, cells ${cellIds[0]} and ${cellIds[1]} are the same number but see each other!';
      case HintType.assumptionError:
        return 'Uh oh! it looks like you have made an illogical assumption! Cell ${cellIds[0]} has no valid numbers!';
      case HintType.nakedSingle:
        return 'take a look at what values can be entered into cell ${cellIds[0]}.';
      case HintType.hiddenSingle:
        return 'take a look at where each number can go in ${sector?.name} ${String.fromCharCode(sectorId!+65)}' ;
      case HintType.killer:
        return 'killer hint text' ;
      default:
        return 'There has been an error with this hint! Whoopsies!';
    }
  }
}