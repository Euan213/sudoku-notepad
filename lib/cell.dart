import 'package:flutter/material.dart';
import 'package:sudoku_notepad/cellColours.dart';


class Cell {

  List<int> coord;
  bool isNull;
  bool isFixed;
  late int boxId;

  int num = 0;
  List<bool> pencilCorner = [false, false, false, false, false, false, false, false,false,];
  List<bool> pencilCenter = [false, false, false, false, false, false, false, false,false,];
  Color colour = CellColours.base;

  bool selected = false;
  bool isSeen = false;
  bool isSame = false;

  Cell(this.coord, this.isNull, this.isFixed)
  {
    boxId = coord[0];
  }

  int getNum()
  {
    return num;
  }

  Color getTextColour()
  {
    return CellColours.text;
  }

  int getIndex()
  {
    return((coord[0]*9)+coord[1]);
  }

  fixedNum(int n)
  {
    num = n;
    isFixed = true;
  }
  unfix()
  {
    isFixed=false; 
    num = 0;
  }

  setPencilCorner(int n)
  {
      pencilCorner[n-1] == !pencilCorner[n-1];
  }
  setPencilCenter(int n)
  {
    pencilCenter[n-1] == !pencilCenter[n-1];
  }

  doSelect()
  {
    selected = !selected;
    colour = CellColours.getNewColour(selected, isSame, isSeen);
  }
  
  doSameNum()
  {
    isSame = !isSame;
    colour = CellColours.getNewColour(selected, isSame, isSeen);
  }

  doSeen()
  {
    isSeen = !isSeen;
    colour = CellColours.getNewColour(selected, isSame, isSeen);
  }

  reset()
  {
    isSeen = false;
    isSame = false;
    selected = false;
    colour = CellColours.getNewColour(selected, isSame, isSeen);
  }

}