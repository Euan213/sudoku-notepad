import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sudoku_notepad/cell.dart';
import 'package:sudoku_notepad/buttonMode.dart';
import 'package:sudoku_notepad/sudoku.dart';
import 'package:sudoku_notepad/cellColours.dart';

class Board extends StatefulWidget{
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board>
{
  List<Cell> board = [];
  List<Cell> selected = [];
  ButtonMode mode = ButtonMode.number;

  //list of constraints

  void _populateBoard()
  {
    for (int index=0; index<=80; index++)
    {
      Cell cell;
      switch (index)
      {
        case  0|| 1|| 2||
              9||10||11||
             18||19||20:
          cell = Cell(0, index, false, false);
        case  3|| 4|| 5||
             12||13||14||
             21||22||23:
          cell = Cell(1, index, false, false);
        case 6 || 7|| 8||
             15||16||17||
             24||25||26:
          cell = Cell(2, index, false, false);
        case 27||28||29||
             36||37||38||
             45||46||47:
          cell = Cell(3, index, false, false);
        case 30||31||32||
             39||40||41||
             48||49||50:
          cell = Cell(4, index, false, false);
        case 33||34||35||
             42||43||44||
             51||52||53:
          cell = Cell(5, index, false, false);
        case 54||55||56||
             63||64||65||
             72||73||74:
          cell = Cell(6, index, false, false);
        case 57||58||59||
             66||67||68||
             75||76||77:
          cell = Cell(7, index, false, false);
        case 60||61||62||
             69||70||71||
             78||79||80:
          cell = Cell(8, index, false, false);
        default:
          cell = Cell(-1, index, false, false);
      }
      board.add(cell);
    }
  }

  void setMode(ButtonMode m)
  {
    setState(()
    {
      mode = m;
    });
  }

  List<Cell> checkNeighbors(List<int> indexes, Cell cell)
  {
    List<Cell> neighbors = [];
    for (int index in indexes)
    {
      if (index == -1)
      {
        neighbors.add(cell);
      }
      else{
        neighbors.add(board[index]);
      }
    }
    return neighbors;
  }

  void handleMargins(int i, bool all)
  {
    if (!all)
    {
      Cell cell = board[i];
      List<Cell> neighbors = checkNeighbors(Sudoku.getNeighbors(cell), cell);
      cell.updateMargins(neighbors);
    }else
    {
      for (Cell cell in board)
      {
        List<Cell> neighbors = checkNeighbors(Sudoku.getNeighbors(cell), cell);
        cell.updateMargins(neighbors);
      }
    }
  }

  void handleSameNum(int newNum)
  {
    for (Cell cell in board)
    {
      cell.doSameNum(cell.num==newNum);
    }
  }

  void handleSeen(Cell selectedCell)
  {
    for (Cell cell in board)
    {
      if (cell.isSeen)
      {
        cell.doSeen();
      }
      if(Sudoku.isSeen(selectedCell, cell) && selectedCell.selected)
      {
        cell.doSeen();
      } 
    }
  }

  void clearSelected()
  {
    for (Cell cell in selected)
    {
      cell.reset();
    }
    selected = [];
  }
  
  void setNumber(int n)
  {
    setState(()
    {
      if (selected.length == 1)
      {
        if (selected[0].num == n)
        {
          selected[0].num = 0;
          handleSameNum(0);
        }
        else
        {
        selected[0].num = n;
        handleSameNum(n);        
        } 
      }
    });
  }
  void setPencilCorner(int n)
  {
    setState(() {
      if (selected.length == 1)
      {
        if (n == 0)
        {
          for (int number=0; number <= 8; number++)
          {
            selected[0].pencilCorner[number] = false;
          }
        }
        else 
        {
          selected[0].pencilCorner[n-1] = !selected[0].pencilCorner[n-1];
        }
      }      
    });
  }
  void setPencilCenter(int n)
  {
    setState(() {
      if (selected.length == 1)
      {
        if (n == 0)
        {
          for (int number=0; number <= 8; number++)
          {
            selected[0].pencilCenter[number] = false;
          }
        }
        else 
        {
          selected[0].pencilCenter[n-1] = !selected[0].pencilCenter[n-1];
        }
      }
    });
  }
  void setColour(int n)
  {
    setState(() {
      if (selected.length == 1)
      {
        selected[0].updateColour(n);
      }      
    });

  }

  void select(Cell thisCell) 
  {
    setState(() 
    {
      if (thisCell.selected)
      {
        clearSelected();
        handleSameNum(0);
        handleSeen(thisCell);
      }else
      {
        clearSelected();
        thisCell.doSelect();
        selected.add(thisCell);

        handleSeen(thisCell); 
        handleSameNum(thisCell.num);
      }
    });
  }

  void multiSelect(Cell thisCell)
  {
    print(thisCell.getIndex());
  }

  String display(int num)
  {
    if (num == 0)
    {
      return '';
    }else 
    {
      return '$num';
    }
  }

  InkWell cellDisplay(Cell cell)
  {
    Widget child;
    Alignment alignment;
    if (cell.num != 0)
    {
      alignment = Alignment.center;
      child = Text(
        '${cell.num}',
        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0, color: cell.textColour)
      );
    }
    else if(cell.pencilCenter.contains(true))
    {
      alignment = Alignment.center;
      String txtStr = '';
      for (int i = 0; i <= 8; i++)
      {
        if (cell.pencilCenter[i])
        {
          txtStr += '${i+1}';
        }
      }
      child = FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(txtStr,),
      );
    }
    else if (cell.pencilCorner.contains(true))
    {
      List<Alignment> alignments = const [Alignment.topLeft,    Alignment.topCenter,    Alignment.topRight,
                                          Alignment.centerLeft, Alignment.center,       Alignment.centerRight,
                                          Alignment.bottomLeft, Alignment.bottomCenter, Alignment.bottomRight,];
      alignment = Alignment.center;
      child = Stack(
        children: [for (int i=0; i<=8; i++) Container(
          alignment: alignments[i],
          child: () {
            if(cell.pencilCorner[i])
            {
              return Text(
                '${i+1}', 
                style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1, color: Colors.black),
              );
            }
            return Text('');
          }(),
        )],
      );
    }
    else
    {
      alignment = Alignment.center;
      child = Text('');
    }
    return InkWell(
      onTap: () => select(cell),
      child: Container(
        alignment: alignment,
        color: cell.colour,
        margin: EdgeInsets.only(
          left: cell.leftMargin,
          right: cell.rightMargin,
          top: cell.topMargin,
          bottom: cell.bottomMargin,
        ),
        child: child,
      )
    );
  }

  ElevatedButton inputButtons(int number, ButtonMode mode)
  {
    String textVal = "$number";

    Color colour = Colors.white;
    TextStyle textStyle;
    VoidCallback onPressFunction;
    Widget child;
    if (number==0)
    {
      textVal="X";
      DefaultTextStyle.of(context).style.apply(fontSizeFactor: 4);
    }
    switch (mode)
    {
      case ButtonMode.number:
        onPressFunction =()=> setNumber(number);
        textStyle = DefaultTextStyle.of(context).style.apply(fontSizeFactor: 4);
        child = Text(textVal, style: textStyle);
      case ButtonMode.colour:
        onPressFunction =()=> setColour(number);
        textStyle = TextStyle();
        colour = CellColours.baseColours[number];
        textVal = "";
        child = Text(textVal, style: textStyle);
      case ButtonMode.pencilCenter:
        onPressFunction =()=> setPencilCenter(number);
        textStyle = DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2);
        child = Text(textVal, style: textStyle);
      case ButtonMode.pencilCorner:
        textStyle = TextStyle();
        onPressFunction =()=> setPencilCorner(number);
        child = Text(textVal, style: textStyle); //TODO - make pretty, text icons should appear at correct corner of buttons
        // GridView.builder(
        //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3), 
        //   physics: const NeverScrollableScrollPhysics(),
        //   itemCount: 3,
        //   itemBuilder: (buildContext, index) {
        //     if (number==0)
        //     {
        //       return Text("Clear", style: TextStyle(backgroundColor: Colors.red,),);
        //     }
        //     if (index == number-1)
        //     {
        //       return Text("$number");
        //     }
        //     return Text("o");
        //   },
        // );   
    }
 

    return ElevatedButton(
      onPressed: onPressFunction,
      style: ElevatedButton.styleFrom(backgroundColor: colour),
      child: child,
    );
  }

  void checkSol()
  {
    setState(()
    {
      if (Sudoku.checkSolved(board))
      {

      }
    });
  }
  void resetPlay()
  {
    setState(() 
    {
      for (Cell cell in board)
        {
          if (!cell.isFixed)
          {
            cell.num=0;
            cell.pencilCorner = [false, false, false, false, false, false, false, false, false,];
            cell.pencilCenter = [false, false, false, false, false, false, false, false, false,];
            cell.updateColour(0);
          }
        }    
    });

  }

  @override
  void initState()
  {
    super.initState();
    _populateBoard();
    handleMargins(0, true);
  }

  @override
  Widget build(BuildContext context)
  {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () => checkSol(),
              child: const Text('Play Mode'),
            ),
            ElevatedButton(
              onPressed: () => checkSol(),
              child: const Text('Set Mode'),
            ),
            ElevatedButton(
              onPressed: () => checkSol(),
              child: const Text('Check'),
            ),
            ElevatedButton(
              onPressed: () => resetPlay(),
              child: const Text('reset'),
            ),
          ] 
        ),
        Container(
          margin: const EdgeInsets.all(5),
          color: Colors.black,
          alignment: Alignment.center,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 9,
              childAspectRatio: 1,
              ),
            itemCount: 81,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (buildContext, index)
            {
              Cell cell = board[index];
              return Container(
                color: () {
                  if (cell.selected)
                  {
                    return CellColours.selectedMargin;
                  }
                  return CellColours.notSelectedMargin;
                }(),
                child: cellDisplay(cell),
              );
            },
          ),
          
        ),
        Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => setMode(ButtonMode.number), 
                  child: Text('Numbers')
                ),
                ElevatedButton(
                  onPressed: () => setMode(ButtonMode.pencilCorner), 
                  child: Image.asset('assets/PencilCorner.png'),
                ),
                ElevatedButton(
                  onPressed: () => setMode(ButtonMode.pencilCenter), 
                  child: Text('Center')
                ),
                ElevatedButton(
                  onPressed: () => setMode(ButtonMode.colour), 
                  child: Text('Colour')
                ),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              itemCount:10,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5
              ),
              itemBuilder:(context, number){
                return inputButtons(number, mode);
              }
            ),
          ],
        ),
      ],
    );
  }
}