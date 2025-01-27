import 'package:sudoku_notepad/variant.dart';
import 'package:sudoku_notepad/sudoku.dart';

class Constraint{
  List<int> appliesToIndexes;
  Constraint(this.appliesToIndexes);

  Variant? get type
  {
    return null;
  }

  CheckSolOutcome? checkMe(List<int> nums)
  {
    return null;
  }
}