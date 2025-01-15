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

  static bool checkSolved(List<Cell> board)
  {
    for (Cell cell in board)
    {
      if (cell.num == 0) return false; 
    }
    return true;
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

  static List<Hint> _hiddenSingleSearch(List<List<List<bool>>> sector, HintType type)
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
    hints += _hiddenSingleSearch(rows, HintType.row);
    hints += _hiddenSingleSearch(cols, HintType.column);
    hints += _hiddenSingleSearch(boxes, HintType.box);

    for (Hint hint in hints)
    {
      if(hint.cellIds.isEmpty&&hint.sector==HintType.box)hint.cellIds=_getBoxMembers(hint.sectorId, board);
      if(hint.cellIds.isEmpty&&hint.sector==HintType.row)hint.cellIds=_getRowMembers(hint.sectorId);
      if(hint.cellIds.isEmpty&&hint.sector==HintType.column)hint.cellIds=_getColumnMembers(hint.sectorId);
    }
    return hints;
  }

  static bool _isInputValid(Cell cell, List<Cell> board)
  {
    bool valid = true;
    for(Cell comparer in board)
    {
      if (isSeen(cell, comparer) && cell.num==comparer.num)
      {
        valid = false;
        break;
      }
    }
    return valid;
  }

  static (SolveOutcome, List<Cell>) _basicSolve(List<Cell> board)
  {
    int delme = 0;
    int max = 0;
    List<int> indexStack = [];
    bool backtracked = false;
    for(int i=0; i<81;)
    {  
      if(delme%1000000==0)
      {
        print(delme);
        print('searching');
        print('currently at index $i max index is $max');
      }
      if(i>max)max=i;
      delme++;
      if(board[i].isFixed)
      {
        i++;
        continue;
      }
      if(!backtracked)
      {
        board[i].num = 0;
      }
      backtracked = false;
      
      board[i].num++;
      while(!_isInputValid(board[i], board))
      {
        board[i].num++;
      }
      if(board[i].num>9)
      {
        board[i].num=0;
        backtracked = true;
        if(indexStack.isEmpty)return(SolveOutcome.noSolution, []);
        i = indexStack.removeLast();
        continue;
      }
      if(!backtracked)indexStack.add(i);
      i++;            
    }
    return (SolveOutcome.success, board);
  }

  static (SolveOutcome, List<Cell>) solve(List<Cell> board, List<dynamic> constraints)
  {
    (SolveOutcome, List<Cell>) outcome = _basicSolve(board);
    if(constraints.isEmpty)
    {
      print(outcome);
      return outcome;
      
    }
    return _basicSolve(board);
  }
}