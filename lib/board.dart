import 'package:flutter/material.dart';
import 'package:sudoku_notepad/cell.dart';
import 'package:sudoku_notepad/buttonMode.dart';
import 'package:sudoku_notepad/sudoku.dart';

class Board extends StatefulWidget{
  const Board({Key? key}) : super(key: key);

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board>
{
  List<Cell> board = [];
  List<Cell> selected = [];
  ButtonMode mode = ButtonMode.number;
  List<Color> colours = [ Colors.white, Colors.blue, Colors.red, Colors.yellow, Colors.green, 
                          Colors.pink, Colors.purple, Colors.brown, Colors.orange, Colors.grey];

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

  void handlePadding(int i, bool all)
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
      if (cell.isSame)
      {
        cell.doSameNum();
      }
      if (cell.num==newNum && newNum!=0)
      {
        cell.doSameNum();
      }
    }
  }

  void handleSeen(Cell thisCell)
  {
    for (Cell cell in board)
    {
      if (thisCell.selected && Sudoku.isSeen(thisCell, cell))
      {
        cell.doSeen();
      }else if((Sudoku.isSeen(thisCell, cell) && !cell.isSeen) || ((!Sudoku.isSeen(thisCell, cell) && cell.isSeen)))
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
        handleSameNum(n);
        selected[0].num = n; 
      }
    });
  }
  void setPencilCorner(int n)
  {
      //do stuff
  }
  void setPencilCenter(int n)
  {
    //do someothing
  }
  void setColour()
  {
    //do something
  }

  void select(Cell thisCell) 
  {
    print(thisCell.index);
    setState(() 
    {
      if (thisCell.selected)
      {
        handleSameNum(0);
        handleSeen(thisCell);
        clearSelected();
      }else
      {
        clearSelected();
        handleSeen(thisCell); 
        handleSameNum(thisCell.num);

        thisCell.doSelect();
        selected.add(thisCell);
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
    }else return '$num';
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

  @override
  void initState()
  {
    super.initState();
    _populateBoard();
    handlePadding(0, true);
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
            itemBuilder: (BuildContext, index)
            {
              Cell cell = board[index];
              return InkWell(
                onTap: () => select(cell),
                child: Container(
                  alignment: Alignment.center,
                  color: cell.colour,
                  margin: EdgeInsets.only(
                    left: cell.leftMargin,
                    right: cell.rightMargin,
                    top: cell.topMargin,
                    bottom: cell.bottomMargin,
                  ),
                  child: Text(
                    display(cell.getNum()),
                    style: DefaultTextStyle.of(context).style.apply(
                      fontSizeFactor: 2.0, 
                      color: cell.getTextColour()
                    )
                  ),
                )
              );
            },
          ),
          
        ),
        // Container(
        //   margin: const EdgeInsets.all(5),
        //   color: Colors.black,
        //   alignment: Alignment.center,
        //   child: GridView.builder(
        //     shrinkWrap: true,
        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 3,
        //       childAspectRatio: 1,
        //       crossAxisSpacing: 4,
        //       mainAxisSpacing: 4,
        //       ),
        //     itemCount: 9,
        //     physics: const NeverScrollableScrollPhysics(),
        //     itemBuilder: (buildContext, gridZone){
        //       return Container(
        //         alignment: Alignment.center,
        //         child: GridView.builder(
        //           shrinkWrap: true,
        //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //             crossAxisCount: 3,
        //             childAspectRatio: 1,
        //             crossAxisSpacing: 2,
        //             mainAxisSpacing: 2,
        //             ),
        //           itemCount: 9,
        //           physics: const NeverScrollableScrollPhysics(),
        //           itemBuilder: (buildContext, position){
        //             int index = (gridZone*9)+position;
        //             if (board.length < index+1) 
        //             {
        //               Cell cell = Cell([gridZone, position], false, false);
        //               board.add(cell);
        //             }
        //             Cell cell = board[index];
        //             return InkWell(
        //               onTap:() => select(cell),
        //               child: GestureDetector(
        //                 onPanUpdate: (details) => multiSelect(cell),
        //                 child: Container(
        //                   alignment: Alignment.center,
        //                   color: cell.colour,
        //                   child: Text(
        //                     display(cell.getNum()),
        //                     style: DefaultTextStyle.of(context).style.apply(
        //                       fontSizeFactor: 2.0, 
        //                       color: cell.getTextColour()
        //                     ),
        //                   ),
        //                 ),
        //               )
        //             );
        //           },
        //         ),
        //       );
        //     },
        //   ),
        // ),
        Column(
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => setMode(ButtonMode.number), 
                  child: Text('A')
                ),
                ElevatedButton(
                  onPressed: () => setMode(ButtonMode.pencilCorner), 
                  child: Text('B')
                ),
                ElevatedButton(
                  onPressed: () => setMode(ButtonMode.pencilCenter), 
                  child: Text('C')
                ),
                ElevatedButton(
                  onPressed: () => setMode(ButtonMode.colour), 
                  child: Text('D')
                ),
              ],
            ),
            GridView.builder(
              shrinkWrap: true,
              itemCount:10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5
              ),
              itemBuilder:(context, number){
                switch (mode)
                {
                  case ButtonMode.number:
                    return ElevatedButton(
                      child: Text(
                        '$number',
                        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 4),
                      ),
                      onPressed: () => setNumber(number),
                    );
                  case ButtonMode.pencilCorner:
                    return ElevatedButton(
                      child: Text('corner'),
                      onPressed: () => setPencilCorner(number),
                    );
                  case ButtonMode.pencilCenter:
                    return ElevatedButton(
                      child: Text('center'),
                      onPressed: () => setPencilCenter(number),
                    );
                  case ButtonMode.colour:
                    return ElevatedButton(
                      child: Text('colour'),
                      onPressed: () => setColour(),
                    );
                }
              }
            ),
          ],
        ),
      ],
    );
  }
}