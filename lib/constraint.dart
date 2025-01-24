import 'package:sudoku_notepad/variant.dart';

class Constraint{
    final Variant type;
    List<int> appliesToIndexes;
    bool satisfied = false; // for use in auto-solving and hints
    Constraint(this.type, this.appliesToIndexes);
}