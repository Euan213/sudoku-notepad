import 'package:sudoku_notepad/cell.dart';
import 'package:sudoku_notepad/hint.dart';
import 'package:sudoku_notepad/hintType.dart';
import 'package:sudoku_notepad/solveOutcome.dart';

class Sudoku
{
  Sudoku._();

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

  static List<bool> getPossibilities(List<Cell> board, Cell forThis)
  {
    List<bool> possible = [true,true,true,true,true,true,true,true,true];
    if (forThis.num != 0 )
    {
      return possible.map((element) => (!element)).toList();
    }
    for (Cell cell in board)
    {
      if (isSeen(forThis, cell) && cell.num!=0)
      { 
        possible[cell.num-1] = false;
      }
    }
    return possible;
  }

  static List<Hint> _hiddenSingleHintSearch(List<List<List<bool>>> sector, HintType type)
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
        for(List<bool> cell in subsec)
        {
          if(cell[i])iCount++;
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

  static List<Hint> getHints(List<Cell> board)
  {
    List<Hint> hints = [];
    int trueCount;

    List<List<List<bool>>> rows = [[],[],[],[],[],[],[],[],[]];
    List<List<List<bool>>> cols = [[],[],[],[],[],[],[],[],[]];
    List<List<List<bool>>> boxes = [[],[],[],[],[],[],[],[],[]];

    for (Cell cell in board)
    {
      for (Cell compareCell in board)
      {
        if (isSeen(cell, compareCell) && cell.num==compareCell.num && cell.num!=0)
        {
          return [Hint(HintType.mistake, [cell.index, compareCell.index,], null)];
        }
        // -- hints that require 2 cells compared can go here
      }

      if (cell.num == 0)
      {
        if (!cell.possibleVals.contains(true))
        {
        return [Hint(HintType.assumptionError, [cell.index], null)];
        }

        trueCount = 0;
        for (bool number in cell.possibleVals)
        {
          if(number) trueCount+=1;
        }
        if (trueCount==1)
        {
          hints.add(Hint(HintType.nakedSingle, [cell.index], null)); 
        }
      }
      rows[cell.index~/9].add(cell.num==0?cell.possibleVals:[false,false,false,false,false,false,false,false,false]);
      cols[cell.index%9].add(cell.num==0?cell.possibleVals:[false,false,false,false,false,false,false,false,false]);
      boxes[cell.boxId].add(cell.num==0?cell.possibleVals:[false,false,false,false,false,false,false,false,false]);
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
    cell.possibleVals = [false,false,false,false,false,false,false,false,false,];
    Set<int> updateUs = _getBoxMembers(cell.boxId, board).toSet();
    updateUs.addAll(_getColumnMembersFromIndex(cell.index));
    updateUs.addAll(_getRowMembersFromIndex(cell.index));
    for(int index in updateUs)
    {
      board[index].possibleVals[cell.num-1] = false;
    }
  }

  static bool _cellHasNoOptionsCheck(List<Cell> board)
  {
    for(Cell cell in board)
    {
      if(!cell.possibleVals.contains(true) && cell.num==0)
      {
        return true;
      }
    }
    return false;
  }

  static bool _fillNakedSingles(List<Cell> board)
  {
    bool change = false;
    int onlyP;
    for(Cell cell in board)
    {
      if(cell.num==0)
      {
        if(cell.possibleVals.where((p) => p==true).length==1)
        {
          onlyP = cell.possibleVals.indexOf(true)+1;
          cell.num = onlyP;
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
    Cell hiddenSingle;
    bool changed = false;

    for(int num=0; num<9; num++)
    {
      occurrences=0;
      for(int i in sector)
      {
        if(board[i].possibleVals[num])
        {
          occurrences++;
        }
      }
      if(occurrences==1)
      {
        hiddenSingle = board[sector.where((index) => board[index].possibleVals[num]).toList()[0]];
        hiddenSingle.num = num+1;
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
        if(board[cell].possibleVals[num-1])
        {
          board[cell].possibleVals[num-1] = false;
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
        Set<int> subset = setA.where((cell) => board[cell].possibleVals[num-1]==true).toSet();
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
    bool changed = false;
    Set<int> seenGroupB;
    Set<int> newSeenGroup;
    Set<int> groupPossibleVals = {};
    Set<int> cellBPossibleVals = {};
    // if(group.contains(30))
    // {
    //   print(group);
    // }
    for(int cell in group)
    {
      for(final (num, exists) in board[cell].possibleVals.indexed)
      {
        if(exists)
        {
          groupPossibleVals.add(num+1);
        }
      }
    }
    if(group.length == groupPossibleVals.length)
    {
      print('group exclusivity applied');
      print(group);
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
      for(final (num, exists) in board[cellB].possibleVals.indexed)
      {
        if(exists)
        {
          cellBPossibleVals.add(num+1);
        }
      }
      print(seenGroupA);
      print('group: $group, group possible vals $groupPossibleVals, cell b $cellB cell b possible vals $cellBPossibleVals');
      if(groupPossibleVals.intersection(cellBPossibleVals).isNotEmpty)
      {
        seenGroupB = {..._getRowMembersFromIndex(cellB), ..._getBoxMembers(board[cellB].boxId, board), ..._getColumnMembersFromIndex(cellB)};
        seenGroupB.remove(cellB);
        newSeenGroup = seenGroupA.intersection(seenGroupB).difference(group);
        print('neeseengrwp $newSeenGroup group $group');
        changed = _recursiveSearchForGroupExclusivity({...group, cellB}, newSeenGroup, board)
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
      Set<int> seenGroup = {..._getRowMembersFromIndex(cell.index), ..._getBoxMembers(cell.boxId, board).toSet(), ..._getColumnMembersFromIndex(cell.index)};
      seenGroup.remove(cell.index);
      changed = changed
              | _recursiveSearchForGroupExclusivity(group, seenGroup, board);
    }
    return changed;
  }

  static SolveOutcome logicalSolve(List<Cell> board)
  {
    Cell cell;
    for(cell in board)
    {
      cell.possibleVals = getPossibilities(board, cell);
    }
    bool tryAgain = true;
    bool error = false;
    while(tryAgain && !error)
    {
      error = _cellHasNoOptionsCheck(board);
      // try{
      tryAgain = _fillNakedSingles(board) 
               | _fillHiddenSingles(board)
               | _setTheoryChecker(board)
               | _groupExclusivityChecker(board);
      // }catch(e){}
      // tryAgain = false;
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