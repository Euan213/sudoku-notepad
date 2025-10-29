import 'package:flutter/material.dart';
import 'package:sudoku_notepad/cellColours.dart';
import 'package:sudoku_notepad/marginType.dart';
import 'package:sudoku_notepad/sudoku.dart';
import 'package:sudoku_notepad/saveData.dart';

class Cell implements saveData{
  final int index;
  int boxId;
  bool isFixed = false;

  double topMargin = 1.0;
  double bottomMargin = 1.0;
  double leftMargin = 1.0;
  double rightMargin = 1.0;

  int num = 0;
  Set<int> pencilCorner = {};
  Set<int> pencilCentre = {};
  Set<int> possibleVals = {};
  int _baseColourId = 0;
  Color colour = CellColours.baseColours[0];
  Color textColour = CellColours.fixedText;
  Color marginColour = CellColours.base;
  bool onHint = false;

  bool selected = false;

  Cell(this.boxId, this.index);
  
  @override
  Map<String, dynamic> toJson() 
  {
    return {"index":index, "boxId":boxId, "fixed":isFixed, "num":num, "corner":pencilCorner.toList(), "centre":pencilCentre.toList(), "colour":_baseColourId};
  }
  void fromJson({required Set<dynamic> corner, required Set<dynamic> centre})
  {
    for (var num in corner) {
      pencilCorner.add(num);
    }
    for (var num in centre) {
      pencilCentre.add(num);
    }
  }

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
    textColour = CellColours.getTextColour(isFixed: isFixed);
  }
  void unfix()
  {
    isFixed=false; 
    num = 0;
  }

  void setPencilCorner(int n)
  {
    pencilCorner.contains(n)? pencilCorner.remove(n) : pencilCorner.add(n);
  }
  void setpencilCentre(int n)
  {
    pencilCentre.contains(n)? pencilCentre.remove(n) : pencilCentre.add(n);
  }

  void changeHintStatus()
  {
    onHint = !onHint;
  }

  void doSelect()
  {
    selected = !selected;
    colour = CellColours.getNewColour(baseId:_baseColourId, selected: selected);
  }

  void reset()
  {
    selected = false;
    colour = CellColours.getNewColour(baseId:_baseColourId, selected:selected);
    textColour = CellColours.getTextColour();
  }

  void getColour({required bool setMode,
                  required bool isSeen,
                  required bool selected,
                  bool settingJigsaw=false})
  {
    colour = CellColours.getNewColour(baseId:_baseColourId, isSetMode:setMode, seen:isSeen, selected:selected, hinting: onHint, settingJigsaw: settingJigsaw);
  }

    void updateBaseId(int newId)
  {
    _baseColourId = newId;
  }

  void updateTextColour()
  {
    textColour = CellColours.getTextColour();
  }

  void updateMarginColour(MarginType type)
  {
    switch(type)
    {
      case MarginType.base:
        marginColour = CellColours.base;

      case MarginType.hint:
        marginColour = CellColours.hintMargin;
    }
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