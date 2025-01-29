import 'package:sudoku_notepad/constraint.dart';
import 'package:sudoku_notepad/sudoku.dart';
import 'package:sudoku_notepad/variant.dart';
import 'package:sudoku_notepad/cell.dart';

class KillerConstraint extends Constraint
{
  int sum;
  @override

  KillerConstraint(super.appliesToIndexes, this.sum);

  @override
  Variant? get type
  {
    return Variant.killer;
  }

  @override
  CheckSolOutcome? checkMe(List<int> nums) 
  {
    int realSum = 0;
    for(int num in nums)
    {
      if(nums.toSet().length != nums.length)
      {
        return CheckSolOutcome.killerExclusivityViolated;
      }
      realSum+=num;
      if(realSum > sum && sum!=0)
      {
        return CheckSolOutcome.killerSumViolated;
      }
    }
    return null;
  }

  @override
  String asString()
  {
    return 'killer,${appliesToIndexes.join('.')},$sum';
  }

  (int, List<int>) _getRemainingSumAndCells(List<Cell> board)
  {
    List<int> cells = [];
    int remainingSum = sum;
    final indexesSet = appliesToIndexes.toSet();
    for(int cell in appliesToIndexes)
    {
      if(board[cell].num == 0)
      {
        cells.add(cell);
      }
      else
      {
        remainingSum =- board[cell].num;
      }
    }
    return (remainingSum, cells);
  }
  @override
  SolveOutcome solveControler(bool forSolve) {
    // TODO: implement solveControler
    return super.solveControler(forSolve);
  }

  // logic Rules for solving and hints - all return a list of cells to update and a set of vals to remove as possibilities
  (List<Cell>?, Set<int>?) singleRemainingCellCheck(List<Cell> board)
  {
    final (remainingSum, remainingCells) = _getRemainingSumAndCells(board);
    if(remainingCells.length == appliesToIndexes.length-1)
    {
      return(remainingCells.map((i) => board[i]).toList(), {1,2,3,4,5,6,7,8,9}.difference({remainingSum}));
    }
    return(null, null);
  }
}