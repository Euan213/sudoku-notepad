import 'dart:collection';

import 'package:sudoku_notepad/variant.dart';
import 'package:sudoku_notepad/sudoku.dart';
import 'package:sudoku_notepad/cell.dart';

class Constraint{
  List<int> appliesToIndexes;
  Constraint(this.appliesToIndexes);

  Variant? get type
  {
    return null;
  }

  CheckSolOutcome? checkMe(List<int> nums)
  {
    throw 'not implemented checkMe()';
  }

  String asString()
  {
    throw 'not implemented asString()';
  }

  HashMap<int, List<int>>? solveControler(bool forSolve, List<Cell> board)
  {
    throw 'not implemented solveControler()';
  }
}