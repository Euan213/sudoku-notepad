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

  void setMode(ButtonMode m)
  {
    setState(()
    {
      mode = m;
    });
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
          // child: Text('banana'),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              ),
            itemCount: 9,
            itemBuilder: (buildContext, gridZone){
              return Container(
                alignment: Alignment.center,
                // child: Text('banana'),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    ),
                  itemCount: 9,
                  itemBuilder: (buildContext, position){
                    int index = (gridZone*9)+position;
                    if (board.length < index+1) 
                    {
                      Cell cell = Cell([gridZone, position], false, false);
                      board.add(cell);
                    }
                    Cell cell = board[index];
                    return InkWell(
                      onTap:() => select(cell),
                      child: GestureDetector(
                        onPanUpdate: (details) => multiSelect(cell),
                        child: Container(
                          alignment: Alignment.center,
                          color: cell.colour,
                          child: Text(
                            display(cell.getNum()),
                            style: DefaultTextStyle.of(context).style.apply(
                              fontSizeFactor: 2.0, 
                              color: cell.getTextColour()
                            ),
                          ),
                        ),
                      )
                    );
                  },
                ),
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