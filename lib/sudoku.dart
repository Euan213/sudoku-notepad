import 'package:sudoku_notepad/cell.dart';

class Sudoku
{
  Sudoku._();

  static bool sameRow(Cell cell_1, Cell cell_2)
  {
    return (cell_1.coord[0]~/3 == cell_2.coord[0]~/3 && cell_1.coord[1]~/3 == cell_2.coord[1]~/3);
  }
  static bool sameColumn(Cell cell_1, Cell cell_2)
  {
    return (cell_1.coord[1]%3 == cell_2.coord[1]%3 && cell_1.coord[0]%3 == cell_2.coord[0]%3);
  }
  static bool sameBox(Cell cell_1, Cell cell_2)
  {
    return(cell_1.boxId == cell_2.boxId);
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