import 'package:sudoku_notepad/variant.dart';

class Constraint{
    final Variant type;
    List<int> appliesToIndexes;
    Constraint(this.type, this.appliesToIndexes);
}