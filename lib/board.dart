import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';
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
  List<List<int>> sameNum = [[0],[],[],[],[],[],[],[],[],[],]; //i 0 is buffer, i 1 is a list of all 1's indices etc.
  List<Cell> board = [];
  List<Cell> selected = [];
  List<Cell> seen = [];
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
    int oldNum = sameNum[0][0];
    if (newNum == 0){
      for (int index in sameNum[newNum])
      {
        board[index].sameNum();
      }
    }
    if(oldNum != 0)
    {
      for (int index in sameNum[oldNum])
      {
        board[index].diffNum();
      }
    }
  }

  void clearSelected()
  {
    for (Cell cell in selected)
    {
      cell.unselect();
    }
    selected = [];
  }
  void clearSeen()
  {
    for (Cell cell in seen)
    {
      cell.unseen();
      cell.textColour = Colors.black;
    }
    seen = [];
  }
  
  void setNumber(int n)
  {
    bool valid = true;
    setState(()
    {
      if (selected.length == 1)
      {
        for (Cell cell in seen)
        {
          if (cell.num == n && !cell.selected)
          {
            cell.textColour = Colors.red;
            valid = false;
          }
        }
        if (valid || n==0)
        {
          sameNum[0][0]=n;
          sameNum[n].remove(selected[0].getIndex()); //IMPORTANT ZONE
          selected[0].num = n;
        }
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
    bool isSelected = thisCell.selected;
    setState(() 
    {
      clearSelected();
      clearSeen();
      handleSameNum(thisCell.num);
      sameNum[0][0] = thisCell.num;
      if (!isSelected)
      {
        for (Cell cell in board) //loop over coords rather than every cell in board
        {
          if (Sudoku.sameBox(thisCell, cell) || Sudoku.sameColumn(thisCell, cell) || Sudoku.sameRow(thisCell, cell))
          {
            cell.seen();
            seen.add(cell);
          }
        }
        for (int index in sameNum[thisCell.getNum()])
        {
          board[index].sameNum();
        }
        thisCell.select();
        selected.add(thisCell);
      }else
      {
        handleSameNum(0);
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