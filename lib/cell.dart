import 'package:flutter/material.dart';

class Cell {
  late int boxId;
  List<int> coord;
  int num = 0;
  List<bool> pencilCorner = [false, false, false, false, false, false, false, false,false,];
  List<bool> pencilCenter = [false, false, false, false, false, false, false, false,false,];
  bool isNull;
  bool isFixed;
  bool selected = false;
  bool seenBySelectedCell = false;

  Color colour = const Color.fromARGB(255, 251, 228, 184);
  Color base = const Color.fromARGB(255, 251, 228, 184);
  Color sameNumHighlighter = Colors.green;//const Color.fromARGB(105, 255, 224, 187);
  Color seenHighlighter = const Color.fromARGB(72, 162, 161, 162);
  Color textColour = Colors.black;

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
    return textColour;
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

  select()
  {
    selected = true; 
    colour = Colors.yellow;
  }
  unselect()
  {
    selected = false; 
    colour = base;
  }
  
  sameNum()
  {
    colour = Color.alphaBlend(sameNumHighlighter, base);
  }
  diffNum()
  {
    colour = base;
  }

  seen()
  {
    seenBySelectedCell = true;
    colour = Color.alphaBlend(seenHighlighter, base);
  }
  unseen()
  {
    seenBySelectedCell = false; 
    colour = base;
  }
}