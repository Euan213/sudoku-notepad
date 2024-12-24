import 'package:sudoku_notepad/cell.dart';

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
    print(neighbors);
    print(cell.index);
    return neighbors;
  }

  static bool checkSolved(List<Cell> board)
  {
    for (Cell cell in board)
    {
      if (cell.num == 0) return false; 
    }
    return true;
  }

}