import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sudoku_notepad/cellColours.dart';
import 'package:sudoku_notepad/sudoku.dart';

class Cell {

  int index;
  int boxId;
  bool isNull;
  bool isFixed;

  double topMargin = 1.0;
  double bottomMargin = 1.0;
  double leftMargin = 1.0;
  double rightMargin = 1.0;

  int num = 0;
  List<bool> pencilCorner = [false, false, false, false, false, false, false, false, false,];
  List<bool> pencilCenter = [false, false, false, false, false, false, false, false, false,];
  int baseColourID = 0;
  Color colour = CellColours.baseColours[0];
  Color textColour = CellColours.text;

  bool selected = false;
  bool isSeen = false;
  bool isSame = false;

  Cell(this.boxId, this.index, this.isNull, this.isFixed);

  int getNum()
  {
    return num;
  }

  int getIndex()
  {
    return(index);
  }

  void fixedNum(int n)
  {
    num = n;
    isFixed = true;
  }
  void unfix()
  {
    isFixed=false; 
    num = 0;
  }

  void setPencilCorner(int n)
  {
      pencilCorner[n-1] == !pencilCorner[n-1];
  }
  void setPencilCenter(int n)
  {
    pencilCenter[n-1] == !pencilCenter[n-1];
  }

  void doSelect()
  {
    selected = !selected;
    colour = CellColours.getNewColour(baseColourID, selected, isSeen);
  }
  
  void doSameNum(bool same)
  {
    textColour = CellColours.getTextColour(same);
  }

  void doSeen()
  {
    isSeen = !isSeen;
    colour = CellColours.getNewColour(baseColourID, selected, isSeen);
  }

  void reset()
  {
    isSeen = false;
    isSame = false;
    selected = false;
    colour = CellColours.getNewColour(baseColourID, selected, isSeen);
  }

  void updateColour(int newID)
  {
    baseColourID = newID;
    colour = CellColours.getNewColour(baseColourID, selected, isSeen);
  }

  void updateMargins(List<Cell> neighbors)
  {
      var [right, left, top, bottom] = neighbors.map((cell) => cell.index).toList();

      if (index!=right && Sudoku.sameBox(this, neighbors[0]))
      {
        rightMargin = 1.0;
      }else 
      {
        rightMargin=2.0;
      }
      if (index!=left && Sudoku.sameBox(this, neighbors[1]))
      {
        leftMargin = 1.0;
      }else 
      {
        leftMargin=2.0;
      }
      if (index!=top && Sudoku.sameBox(this, neighbors[2]))
      {
        topMargin = 1.0;
      }else 
      {
        topMargin=2.0;
      }
      if (index!=bottom && Sudoku.sameBox(this, neighbors[3]))
      {
        bottomMargin = 1.0;
      }else 
      {
        bottomMargin=2.0;
      }
  }
}