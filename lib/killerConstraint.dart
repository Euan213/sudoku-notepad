import 'dart:collection';

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
  HashMap<int, List<int>>? solveControler(bool forSolve, List<Cell> board) 
  {
    List<int>? updateUs;
    Set<int>? impossibles;
    HashMap<int, List<int>> instructions = HashMap();
    if(forSolve)
    {
      (updateUs, impossibles) = singleRemainingCellCheck(board);
      if(updateUs!=null)
      {
        for(int n in impossibles!)
        {
          if (instructions.containsKey(n))
          {
            instructions[n] = updateUs;
          }else{
            instructions[n]?.addAll(updateUs);
          }
        }
      }
    }
    return instructions;
  }

  // logic Rules for solving and hints - all return a list of cells to update and a set of vals to remove as possibilities
  (List<int>?, Set<int>?) singleRemainingCellCheck(List<Cell> board)
  {
    final (remainingSum, remainingCells) = _getRemainingSumAndCells(board);
    if(remainingCells.length == 1)
    {
      return(remainingCells, {1,2,3,4,5,6,7,8,9}.difference({remainingSum}));
    }
    return(null, null);
  }
}