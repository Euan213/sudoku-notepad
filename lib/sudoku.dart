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
    return (_sameRow(cell_1, cell_2) || _sameColumn(cell_1, cell_2) || sameBox(cell_1, cell_2));
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
        if (isSeen(cell, compareCell) && cell.num==compareCell.num && cell.num!=0 && cell.index!=compareCell.index)
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
  (SolveOutcome, List<Cell>) _basicSolve(List<Cell> board)
  {
    List<int> indexStack = [];
    bool backtracked = false;
    bool valid = true;
    for(int i=0; i<81; i++)
    {
      if(board[i].isFixed)continue;

      if(backtracked)
      {
        board[i].num = 0;
        backtracked = false;
      }
      while(board[i].num<10)
      {
        valid = true;
        board[i].num++;
        for(Cell cell in board)
        {
          if (isSeen(board[i], cell) && board[i].num==cell.num && board[i].index!=cell.index)
          {
            valid = false;
            break;
          }
        }
        if(valid)break;
      }
      if(valid)continue;
      backtracked = true;
      i = indexStack.removeLast()-1;
    }
    return (SolveOutcome.success, board);
  }

  (SolveOutcome, List<Cell>) solve(List<Cell> board, List<dynamic> constraints)
  {
    (SolveOutcome, List<Cell>) outcome, potential = _basicSolve(board);
    if(constraints.isEmpty)
    {
      return _basicSolve(board);
    }
    return _basicSolve(board);
  }
}