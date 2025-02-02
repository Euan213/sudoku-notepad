import 'dart:collection';

import 'package:sudoku_notepad/constraint.dart';
import 'package:sudoku_notepad/sudoku.dart';
import 'package:sudoku_notepad/variant.dart';
import 'package:sudoku_notepad/cell.dart';

class KillerConstraint extends Constraint
{
  int recs=0;

  int sum;
  Set<int> mustContain = {};
  @override
  bool get isExclusive
  {
    return true;
  }
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
    for(int cell in appliesToIndexes)
    {
      if(board[cell].num == 0)
      {
        cells.add(cell);
      }
      else
      {
        remainingSum -= board[cell].num;
      }
    }
    return (remainingSum, cells);
  }
  @override
  HashMap<int, List<int>> solveControler(bool forSolve, List<Cell> board) 
  {
    mustContain = {};
    List<int> cells = [];
    Set<int> nums = {};
    HashMap<int, List<int>> instructions = HashMap();
    if(forSolve)
    {
      // (cells, nums) = _singleRemainingCell(board);
      // _updateInstructions(cells, nums, instructions);

      (cells, nums) = _cageExclusivity(board);
      _updateInstructions(cells, nums, instructions);

      (cells, nums) = _possibleCombosExclusions(board);
      _updateInstructions(cells, nums, instructions);
    }
    return instructions;
  }

  void _updateInstructions(List<int> cells, Set<int> nums, HashMap<int, List<int>> instructions)
  {
    if(nums.isNotEmpty)
    {
      for(int n in nums)
      {
        if (instructions.containsKey(n))
        {
          instructions[n]?.addAll(cells);
        }else{
          instructions[n] = cells;
        }
      }
    }    
  }

  // logic Rules for solving and hints - all return a list of cells indexes to update and a set of vals to remove as possibilities
  (List<int>, Set<int>) _cageExclusivity(List<Cell> board)
  {
    Set<int> nums = {};
    for(int index in appliesToIndexes)
    {
      if(board[index].num!=0)
      {
        nums.add(board[index].num);
      }
    }
    return nums.isEmpty? ([],{}) : (appliesToIndexes, nums);
  }

  (List<int>, Set<int>) _singleRemainingCell(List<Cell> board)
  {
    final (remainingSum, remainingCells) = _getRemainingSumAndCells(board);
    if(remainingCells.length == 1 && sum!=0)
    {
      return(remainingCells, {1,2,3,4,5,6,7,8,9}.difference({remainingSum}));
    }
    return([], {});
  }
  (List<int>, Set<int>) _possibleCombosExclusions(List<Cell> board)
  {
    final (remainingSum, remainingCells) = _getRemainingSumAndCells(board);
    Set<Set<int>> combos = {};
    Set<int> cageVals={};

    for(int index in appliesToIndexes)
    {
      cageVals.addAll(board[index].possibleVals);
    }
    recs=0;
    getCombos(combos, remainingSum, cageVals, {}, remainingCells.length);
    print(combos.isNotEmpty?combos.reduce((prev, cur) => prev.union(cur)):'empty');
    return combos.isEmpty? ([],{})
      :(remainingCells, {1,2,3,4,5,6,7,8,9}.difference(combos.reduce((prev, cur) => prev.union(cur))));
  }

  void getCombos(Set<Set<int>> combos, int cageSum, Set<int> cageVals, Set<int> thisCombo, int remainingCells)
  {
    recs++;
    bool addCombo = true;
    int thisSum = thisCombo.fold(0, (prev, current) => prev+current);
    if(thisSum>cageSum) return;
    if(remainingCells==0 && thisSum==cageSum)
    {
      for(Set<int> c in combos)
      {
        if(c.containsAll(thisCombo)) 
        {
          addCombo = false;
          break;
        }
      }
      if(addCombo) combos.add(thisCombo);
      return;
    }
    if(remainingCells==0) return;
    for(int n in cageVals)
    {
      getCombos(combos, cageSum, cageVals.difference({n}), {n, ...thisCombo}, remainingCells-1);
    }
  }
}