import 'dart:collection';

import 'package:sudoku_notepad/cell.dart';
import 'package:sudoku_notepad/constraint.dart';
import 'package:sudoku_notepad/hint.dart';
import 'package:sudoku_notepad/hintType.dart';
import 'package:sudoku_notepad/killerConstraint.dart';
import 'package:sudoku_notepad/variant.dart';


enum SolveOutcome {success, impossible, noSolutionFound}
enum CheckSolOutcome {good, emptyCell, sudokuViolated, killerSumViolated, killerExclusivityViolated}

class Sudoku
{
  Sudoku._();

  static int sum=0;

  static bool _sameRow(Cell cell_1, Cell cell_2)
  {
    return (cell_1.index~/9 == cell_2.index~/9 && cell_1.index~/9 == cell_2.index~/9);
  }
  static bool _sameColumn(Cell cell_1, Cell cell_2)
  {
    return (cell_1.index%9 == cell_2.index%9 && cell_1.index%9 == cell_2.index%9);
  }
  static bool sameBox(Cell cell_1, Cell cell_2)
  {
    return(cell_1.boxId == cell_2.boxId);
  }

  static bool isSeen(Cell cell_1, Cell cell_2)
  {
    return ((_sameRow(cell_1, cell_2) || _sameColumn(cell_1, cell_2) || sameBox(cell_1, cell_2)) && cell_1.index != cell_2.index);
  }

  static int getNumberOfCellsInBox(int boxId, List<Cell> board)
  {
    int count = 0;
    for(Cell cell in board)
    {
      boxId==cell.boxId? count++ : {};
    }
    return count;
  }

  static List<int> getNeighbors(Cell cell)
  {
    // returns an integer list of neighbors for a given cell, in the form:
    // [right, left, above, below].
    // where a neighbor does not exist, i.e, a cell is on the edge of the board a default 
    // value of -1 is inputed in its place in the resulting list.
    int i = cell.index;
    List<int> potentialNeighbors = [i+1, i-1, i-9, i+9]; 
    List<int> neighbors = [];
    for (int n in potentialNeighbors)
    {
      if (n >= 0 && n <= 80 && (i~/9==n~/9 || n==i+9 || n==i-9))
      {
        neighbors.add(n);
      }else
      {
        neighbors.add(-1); //add error value so positions of neigbors in array are maintained even if one or more n are invalid
      }
    }
    return neighbors;
  }

  static List<int> _getBoxMembers(int? id, List<Cell> board)
  { 
    List<int> cells = [];
    for(Cell cell in board)
    {
      if(cell.boxId==id)cells.add(cell.index);
    }
    return cells;
  }
  static List<int> _getRowMembers(int? id)
  {
    int index = id!*9;
    List<int> list=[];

    do
    {
      list.add(index);
      index+=1;
    }while (index%9!=0&&index!=id*9);
    return list;
  }
  static List<int> _getColumnMembers(int? id)
  {
    int? index = id;
    List<int> list=[];
    while (index!<81)
    {
      list.add(index);
      index+=9;
    }
    index=id;
    while (index!>=0)
    {
      if(!list.contains(index))list.add(index);
      index-=9;
    }
    return list;
  }

  static Set<int> _getRowMembersFromIndex(int index )
  {
    Set<int> m = {};
    int id = index;
    while(id~/9 == index~/9 && id>= 0)
    {
      m.add(id);
      id--;
    }
    id = index;
    while(id~/9 == index~/9)
    {
      m.add(id);
      id++;
    }
    return m;
  }
  static Set<int> _getColumnMembersFromIndex(int index)
  {
    Set<int> m = {};
    int id = index;
    while(id>= 0)
    {
      m.add(id);
      id-=9;
    }
    id = index;
    while(id<=80)
    {
      m.add(id);
      id+=9;
    }
    return m;
  }

  static Set<int> getPossibilities(List<Cell> board, Cell forThis)
  {
    Set<int> possible = {1,2,3,4,5,6,7,8,9};
    if (forThis.num != 0 )
    {
      return {};
    }
    for (Cell cell in board)
    {
      if (isSeen(forThis, cell))
      { 
        possible.remove(cell.num);
      }
    }
    return possible;
  }

  static List<Hint> _hiddenSingleHintSearch(List<List<Set<int>>> sector, HintType type)
  {
    List<Hint> hints = [];
    Hint newHint;
    List<int> timesAppeared;
    for(final (sectorNum, subsec) in sector.indexed)
    {
      timesAppeared = [];
      for(int i=0; i<9; i++)
      {
        int iCount = 0;
        for(Set<int> cell in subsec)
        {
          if(cell.contains(i))iCount++;
        }
        timesAppeared.add(iCount);
      }
      for(int num in timesAppeared)
      {
        if (num==1) 
        {
        newHint = Hint(HintType.hiddenSingle, [], type);
        newHint.sectorId = sectorNum;
        hints.add(newHint);
        }
      }
    }
    return hints;
  }

  static Cell? _conflictCheck (Cell cell, List<Cell> board)
  {
    for (Cell compareCell in board)
    {
      if (isSeen(cell, compareCell) && cell.num==compareCell.num && cell.num!=0)
      {
        return compareCell;
      }
    }
    return null;
  }

  static List<Hint> getHints(List<Cell> board)
  {
    List<Hint> hints = [];

    List<List<Set<int>>> rows = [[],[],[],[],[],[],[],[],[]];
    List<List<Set<int>>> cols = [[],[],[],[],[],[],[],[],[]];
    List<List<Set<int>>> boxes = [[],[],[],[],[],[],[],[],[]];

    for (Cell cell in board)
    {
      Cell? mistakeCell = _conflictCheck(cell, board);
      if(mistakeCell!=null)
      {
        return [Hint(HintType.mistake, [cell.index, mistakeCell.index,], null)];
      }

      if (cell.num == 0)
      {
        if (cell.possibleVals.isEmpty)
        {
          return [Hint(HintType.assumptionError, [cell.index], null)];
        }
        if (cell.possibleVals.isEmpty)
        {
          hints.add(Hint(HintType.nakedSingle, [cell.index], null)); 
        }
      }
      rows[cell.index~/9].add(cell.num==0?cell.possibleVals:{});
      cols[cell.index%9].add(cell.num==0?cell.possibleVals:{});
      boxes[cell.boxId].add(cell.num==0?cell.possibleVals:{});
    }
    hints += _hiddenSingleHintSearch(rows, HintType.row);
    hints += _hiddenSingleHintSearch(cols, HintType.column);
    hints += _hiddenSingleHintSearch(boxes, HintType.box);

    for (Hint hint in hints)
    {
      if(hint.cellIds.isEmpty&&hint.sector==HintType.box)hint.cellIds=_getBoxMembers(hint.sectorId, board);
      if(hint.cellIds.isEmpty&&hint.sector==HintType.row)hint.cellIds=_getRowMembers(hint.sectorId);
      if(hint.cellIds.isEmpty&&hint.sector==HintType.column)hint.cellIds=_getColumnMembers(hint.sectorId);
    }
    return hints;
  }

  static void _updatePossibleValsOnInput(Cell cell, List<Cell> board)
  {
    cell.possibleVals = {};
    Set<int> updateUs = _getBoxMembers(cell.boxId, board).toSet();
    updateUs.addAll(_getColumnMembersFromIndex(cell.index));
    updateUs.addAll(_getRowMembersFromIndex(cell.index));
    for(int index in updateUs)
    {
      board[index].possibleVals.remove(cell.num);
    }
  }

  static (CheckSolOutcome, Set<Cell>) checkSolIsGood(List<Cell> board, List<dynamic> constraints)
  {
    CheckSolOutcome? outcome;
    Cell? badCell;
    for(Cell cell in board)
    {
      if(cell.num==0)
      {
        outcome = CheckSolOutcome.emptyCell;
        return (outcome, {cell});
      }
      badCell = _conflictCheck(cell, board);
      if(badCell!=null)
      {
        outcome = CheckSolOutcome.sudokuViolated;
        return (outcome, {cell, badCell});
      }
    }
    for(Constraint c in constraints)
    {
      outcome = c.checkMe(c.appliesToIndexes.map((int id) => board[id].num).toList());
      if(outcome!=null){
        return (outcome, c.appliesToIndexes.map((id) => board[id]).toSet());
      }
    }
    return (CheckSolOutcome.good, {});
  }

  static bool _cellHasNoOptionsCheck(List<Cell> board)
  {
    for(Cell cell in board)
    {
      if(!cell.possibleVals.isNotEmpty && cell.num==0)
      {
        return true;
      }
    }
    return false;
  }

  static bool _fillNakedSingles(List<Cell> board)
  {
    bool change = false;
    for(Cell cell in board)
    {
      if(cell.num==0)
      {
        if(cell.possibleVals.length==1)
        {
          cell.num = cell.possibleVals.elementAt(0);
          change = true;
          _updatePossibleValsOnInput(cell, board);
        }
      }
    }
    return change;
  }

  static bool _loopOverSectorsForHiddenSingle(Set<int> sector, List<Cell> board)
  {
    int occurrences;
    Cell? hiddenSingle;
    bool changed = false;

    for(int num=1; num<10; num++)
    {
      occurrences=0;
      for(int i in sector)
      {
        if(board[i].possibleVals.contains(num))
        {
          occurrences++;
          hiddenSingle = board[i];
        }
        
      }
      if(occurrences==1)
      {
        hiddenSingle!.num = num;
        _updatePossibleValsOnInput(hiddenSingle, board);
        changed = true;
      }
    }
    return changed;
  }

  static bool _fillHiddenSingles(List<Cell> board)
  {
    Set<int> row;
    Set<int> col;
    List<int> box;
    bool changed = false;
    for(int sectorId=0; sectorId<9; sectorId++)
    {
      row = _getRowMembersFromIndex(sectorId);
      box = _getBoxMembers(sectorId, board);
      col = _getColumnMembersFromIndex(sectorId);
      changed = _loopOverSectorsForHiddenSingle(row, board) 
              | _loopOverSectorsForHiddenSingle(col, board) 
              | _loopOverSectorsForHiddenSingle(box.toSet(), board)
              | changed;
    }
    return changed;
  }

  static bool _tryUpdatePossibleValsOfSet(Set<int> set, Set<int> nums, List<Cell> board)
  {
    bool changed = false;
    for(int num in nums)
    {
      for(int cell in set)
      {
        if(board[cell].possibleVals.contains(num))
        {
          board[cell].possibleVals.remove(num);
          changed = true;
          print('deduction applied to cell $cell to remove $num as an option');
        }
      }
    }
    return changed;
  }

  static bool _setTheoryChecker(List<Cell> board)
  {
    List<Set<int>> boxes = [];
    List<Set<int>> rows = [];
    List<Set<int>> cols = [];
    bool changed = false;
    Set<int> setBWithoutSubset;

    for(int i=0; i<9; i++)
    {
      boxes.add(_getBoxMembers(i, board).toSet());
      rows.add(_getRowMembers(i).toSet());
      cols.add(_getColumnMembers(i).toSet());
    }
    for(Set<int> setA in [...boxes, ...rows, ...cols])
    {
      for(int num=1; num<=9; num++)
      {
        Set<int> subset = setA.where((cell) => board[cell].possibleVals.contains(num)).toSet();
        for(Set<int> setB in [...boxes, ...rows, ...cols])
        {
          if(setB.containsAll(subset) && subset.isNotEmpty && setB != setA)
          {
            print('set theory applied');
            print(subset);
            setBWithoutSubset = setB.difference(subset);

            changed = _tryUpdatePossibleValsOfSet(setBWithoutSubset, {num}, board);
          }
        }
      }
    }
    return changed;
  }

  static bool _recursiveSearchForGroupExclusivity(Set<int> group, Set<int> seenGroupA, List<Cell> board)
  {
    sum++;
    bool changed = false;
    Set<int> seenGroupB;
    Set<int> newSeenGroup;
    Set<int> groupPossibleVals = {};
    Set<int> alreadyChecked={};
    for(int cell in group)
    {
      groupPossibleVals.addAll(board[cell].possibleVals);
    }
    if(group.length == groupPossibleVals.length)
    {
      print('group exclusivity applied');
      print('group: $group with possible vals: $groupPossibleVals');
      Set<int> row = _getRowMembersFromIndex(group.toList()[0]);
      Set<int> col = _getColumnMembersFromIndex(group.toList()[0]);
      Set<int> box = _getBoxMembers(board[group.toList()[0]].boxId, board).toSet();
      if(row.containsAll(group))
      {
        changed = _tryUpdatePossibleValsOfSet(row.difference(group), groupPossibleVals, board);
      }
      if(col.containsAll(group))
      {
        changed = _tryUpdatePossibleValsOfSet(col.difference(group), groupPossibleVals, board);
      }
      if(box.containsAll(group))
      {
        changed = _tryUpdatePossibleValsOfSet(box.difference(group), groupPossibleVals, board);
      }
      return changed;
    } 
    if(group.length==8 || groupPossibleVals.length==8)
    {
      return false;
    }

    for(int cellB in seenGroupA)
    {
      alreadyChecked.add(cellB);
      if(groupPossibleVals.intersection(board[cellB].possibleVals).isNotEmpty)
      {
        seenGroupB = {..._getRowMembersFromIndex(cellB), ..._getBoxMembers(board[cellB].boxId, board), ..._getColumnMembersFromIndex(cellB)}.where((index) => board[index].num==0).toSet();
        seenGroupB.remove(cellB);
        newSeenGroup = seenGroupA.intersection(seenGroupB).difference(group);
        changed = _recursiveSearchForGroupExclusivity({...group, cellB}, newSeenGroup.difference(alreadyChecked), board)
                | changed;
      }
    }
    return changed;
  }

  static bool _groupExclusivityChecker(List<Cell> board)
  {
    bool changed = false;
    for(Cell cell in board)
    {
      if(cell.num!=0)continue;
      Set<int> group = {cell.index}; 
      Set<int> seenGroup = {..._getRowMembersFromIndex(cell.index), 
                            ..._getBoxMembers(cell.boxId, board).toSet(), 
                            ..._getColumnMembersFromIndex(cell.index)
      }.where((index) => board[index].num==0).toSet();
      seenGroup.remove(cell.index);
      changed = changed
              | _recursiveSearchForGroupExclusivity(group, seenGroup, board);
    }
    return changed;
  }

  static bool _killerSolver(List<Cell> board, List<dynamic> variants)
  {
    bool changed = false;
    List<Cell> remainingCells;
    int remainingSum;
    Set<int> optionsAvailableForCage;
    Set<Set<int>> cageComboOptions;
    List<KillerConstraint> cages = variants.where((dynamic c) => c.type==Variant.killer).toList() as List<KillerConstraint>;
    for(KillerConstraint c in cages)
    {
      remainingSum = c.sum;
      optionsAvailableForCage = {};
      remainingCells = [];
      cageComboOptions = {};
      for(int index in c.appliesToIndexes)
      {
        if(board[index].num==0)
        {
          remainingCells.add(board[index]);
          optionsAvailableForCage.addAll(board[index].possibleVals);
        }else
        {
          remainingSum-=board[index].num;
        }
      }
      if(remainingCells.isEmpty)
      {
        continue;
      }
      
    }
    return changed;
  }

  static SolveOutcome logicalSolve(List<Cell> board, List<dynamic> variants)
  {
    sum=0;
    Cell cell;
    for(cell in board)
    {
      cell.possibleVals = getPossibilities(board, cell);
    }
    bool tryAgain = true;
    bool error = false;
    int difficultyIndicator = 0;
    HashMap<int, List<int>>? instructions;
    while(tryAgain && !error)
    {
      print('in while');
      error = _cellHasNoOptionsCheck(board);
      // difficultyIndicator==0?tryAgain = _fillNakedSingles(board) 
      //                                 | _fillHiddenSingles(board)
      // :difficultyIndicator==1? tryAgain = _setTheoryChecker(board)
      // :difficultyIndicator==2? tryAgain = _groupExclusivityChecker(board)
      // :{};

      for(Constraint c in variants)
      {
        print('in constraints');
        instructions = c.solveControler(true, board);
        instructions?.forEach((limitedNum, cells) => (){
          _tryUpdatePossibleValsOfSet(cells.toSet(), {limitedNum}, board);
        });
      }
      tryAgain=false;//remove
      tryAgain? difficultyIndicator=0 : difficultyIndicator++;
    }
    for(cell in board)
    {
      if(cell.num==0)
      {
        print('not solved');
        print('error is $error');
        return SolveOutcome.noSolutionFound;
      }
    }
    return SolveOutcome.success;
  }
  // static bool _isInputValid(Cell cell, List<Cell> board)
  // {
  //   bool valid = true;
  //   for(Cell comparer in board)
  //   {
  //     if (isSeen(cell, comparer) && cell.num==comparer.num)
  //     {
  //       valid = false;
  //       break;
  //     }
  //   }
  //   return valid;
  // }  

  // static (SolveOutcome, List<Cell>) _bruteForce(List<Cell> board)
  // {
  //   int delme = 0;
  //   int max = 0;
  //   List<int> indexStack = [];
  //   bool backtracked = false;
  //   for(int i=0; i<81;)
  //   {  
  //     if(delme%1000000==0)
  //     {
  //       print(delme);
  //       print('searching');
  //       print('currently at index $i max index is $max');
  //     }
  //     if(i>max)max=i;
  //     delme++;
  //     if(board[i].isFixed)
  //     {
  //       i++;
  //       continue;
  //     }
  //     if(!backtracked)
  //     {
  //       board[i].num = 0;
  //     }
  //     backtracked = false;
  //     board[i].num++;
  //     while(!_isInputValid(board[i], board))
  //     {
  //       board[i].num++;
  //     }
  //     if(board[i].num>9)
  //     {
  //       board[i].num=0;
  //       backtracked = true;
  //       if(indexStack.isEmpty)return(SolveOutcome.noSolution, []);
  //       i = indexStack.removeLast();
  //       continue;
  //     }
  //     if(!backtracked)indexStack.add(i);
  //     i++;            
  //   }
  //   return (SolveOutcome.success, board);
  // }

  // static (SolveOutcome, List<Cell>) solve(List<Cell> board, List<dynamic> constraints)
  // {
    // (SolveOutcome, List<Cell>) outcome = _basicSolve(board);
    // if(constraints.isEmpty)
    // {
    //   print(outcome);
    //   return outcome;
    // }
    // return _basicSolve(board);
  // }
}