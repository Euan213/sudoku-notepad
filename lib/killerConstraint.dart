import 'package:sudoku_notepad/constraint.dart';

class KillerConstraint extends Constraint
{
  int sum;
  KillerConstraint(super.type, super.appliesToIndexes, this.sum);
}