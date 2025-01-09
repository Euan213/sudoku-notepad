import 'package:flutter/material.dart';
import 'package:sudoku_notepad/cellColours.dart';
import 'package:sudoku_notepad/marginType.dart';
import 'package:sudoku_notepad/sudoku.dart';

class Cell {
  int index;
  int boxId;
  bool isFixed = false;

  double topMargin = 1.0;
  double bottomMargin = 1.0;
  double leftMargin = 1.0;
  double rightMargin = 1.0;

  int num = 0;
  List<bool> pencilCorner = [false, false, false, false, false, false, false, false, false,];
  List<bool> pencilCenter = [false, false, false, false, false, false, false, false, false,];
  List<bool> possibleVals = [false, false, false, false, false, false, false, false, false,];
  int _baseColourId = 0;
  Color colour = CellColours.baseColours[0];
  Color textColour = CellColours.fixedText;
  Color marginColour = CellColours.notSelectedMargin;

  bool selected = false;

  Cell(this.boxId, this.index);

  int getNum()
  {
    return num;
  }

  int getIndex()
  {
    return(index);
  }

  int getColourId()
  {
    return(_baseColourId);
  }

  void doFixedNum(int n)
  {
    num = n;
    if (n!=0)
    {
      isFixed = true;
      }
    else
    {
      isFixed = false;
    }
    textColour = CellColours.getTextColour(selected, false, isFixed);
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
    updateMarginColour(selected? MarginType.selected:MarginType.base);
    colour = CellColours.getNewColour(_baseColourId, selected, false);
  }
  
  void doSameNum(bool same)
  {
    textColour = CellColours.getTextColour(selected, same, isFixed);
  }

  void doSeen(bool seen)
  {
    colour = CellColours.getNewColour(_baseColourId, selected, seen);
  }

  void reset()
  {
    selected = false;
    colour = CellColours.getNewColour(_baseColourId, selected, false);
    textColour = CellColours.getTextColour(selected, false, isFixed);
  }

  void updateColour(int newID)
  {
    _baseColourId = newID;
    colour = CellColours.getNewColour(_baseColourId, selected, false);
  }

  void updateTextColour()
  {
    textColour = CellColours.getTextColour(selected, false, isFixed);
  }

  void updateMarginColour(MarginType type)
  {
    switch(type)
    {
      case MarginType.base:
        marginColour = CellColours.notSelectedMargin;
      case MarginType.selected:
        marginColour = CellColours.selectedMargin;
      case MarginType.hint:
        marginColour = CellColours.hintMargin;
    }
  }

  void hint()
  {
    colour = Color.alphaBlend(CellColours.hintHighlighter, colour);
    updateMarginColour(MarginType.hint);
  }
  void unHint()
  {
    colour = CellColours.getNewColour(_baseColourId, selected, false);
    updateMarginColour(MarginType.base);
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