import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku_notepad/cell.dart';
import 'package:sudoku_notepad/buttonMode.dart';
import 'package:sudoku_notepad/main.dart';
import 'package:sudoku_notepad/move.dart';
import 'package:sudoku_notepad/saveLoad.dart';
import 'package:sudoku_notepad/sudoku.dart';
import 'package:sudoku_notepad/cellColours.dart';
import 'package:sudoku_notepad/hint.dart';


class Board extends StatefulWidget{
  final String name;
  final int initBoardID;
  final String board;
  final bool boardModePlay;
  final List<String> constraints;
  const Board(this.initBoardID, this.constraints, this.boardModePlay, this.board, this.name, {super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board>
{
  late String name;
  late int boardID;
  var undoHistory = [];
  List<Cell> selected = [];
  ButtonMode mode = ButtonMode.fixedNum;
  DateTime now = DateTime.now();

  List<Cell> board = [];
  late bool boardModePlay;
  late List<String> constraints;

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
          cell = Cell(0, index);
        case  3|| 4|| 5||
             12||13||14||
             21||22||23:
          cell = Cell(1, index);
        case 6 || 7|| 8||
             15||16||17||
             24||25||26:
          cell = Cell(2, index);
        case 27||28||29||
             36||37||38||
             45||46||47:
          cell = Cell(3, index);
        case 30||31||32||
             39||40||41||
             48||49||50:
          cell = Cell(4, index);
        case 33||34||35||
             42||43||44||
             51||52||53:
          cell = Cell(5, index);
        case 54||55||56||
             63||64||65||
             72||73||74:
          cell = Cell(6, index);
        case 57||58||59||
             66||67||68||
             75||76||77:
          cell = Cell(7, index);
        case 60||61||62||
             69||70||71||
             78||79||80:
          cell = Cell(8, index);
        default:
          cell = Cell(-1, index);
      }
      board.add(cell);
    }
  }

  String meAsString()
  {
    String cells = '';
    for (Cell cell in board)
    {
      String centerStr='';
      for (final (index, num) in cell.pencilCenter.indexed)
      {
        if (num)
        {
          centerStr+='${index+1}';
        }
      }
      String cornerStr='';
      for (final (index, num) in cell.pencilCorner.indexed)
      {
        if (num)
        {
          cornerStr+='${index+1}';
        }
      }
      cells+='${cell.isFixed?1:0}.${cell.num}.$centerStr.$cornerStr.${cell.getColourId()}.${cell.boxId},';
    }
    cells = cells.substring(0, cells.length-1);
    return "${constraints.join()}|${boardModePlay?1:0}|$cells|$name";
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
      cell.doSeen(Sudoku.isSeen(selectedCell, cell) && selectedCell.selected);
    }
  }

  void clearSelected()
  {
    for (Cell cell in selected)
    {
      cell.doSelect();
    }
    selected = [];
  }
  
  void setNumber(int n, Cell cell, bool fixed) async
  {
    setState(()
    {
      if (!fixed)
      { 
        if (!cell.isFixed)
        {
          if (cell.num == n)
          {
            cell.num = 0;
            handleSameNum(0);
          }
          else
          {
          cell.num = n;
          handleSameNum(n);        
          } 
        }
      }
      else
      {
        if (selected.length == 1)
        {
          if (cell.num == n)
          {
            cell.doFixedNum(n);
          }
          else
          {
            cell.doFixedNum(n);
          }
        }
      }
    });
    boardID = await SaveLoad.saveBoard(boardID, meAsString());
  }
  void setPencilCorner(int n, Cell cell) async
  {
    setState(() {
      if (n == 0)
      {
        for (int number=0; number <= 8; number++)
        {
          cell.pencilCorner[number] = false;
        }
      }
      else 
      {
        cell.pencilCorner[n-1] = !cell.pencilCorner[n-1];
      }  
    });
    boardID = await SaveLoad.saveBoard(boardID, meAsString());
  }
  void setPencilCenter(int n, Cell cell) async
  {
    setState(() {
      if (n == 0)
      {
        for (int number=0; number <= 8; number++)
        {
          cell.pencilCenter[number] = false;
        }
      }
      else 
      {
        cell.pencilCenter[n-1] = !cell.pencilCenter[n-1];
      }
    });
    boardID = await SaveLoad.saveBoard(boardID, meAsString());

  }
  void setColour(int n, Cell cell) async
  {
    setState(() {
      cell.updateColour(n);
    });
    boardID = await SaveLoad.saveBoard(boardID, meAsString());
  }

  void _doUndo()
  {
    setState(() {
      if(undoHistory.isNotEmpty)
      {
        var move = undoHistory.removeLast();
        switch(move[0])
        {
          case Move.number:
            setNumber(move[2], board[move[1]], false);
          case Move.pencilCenter:
            setPencilCenter(move[2], board[move[1]]);
          case Move.pencilCorner:
            setPencilCorner(move[2], board[move[1]]);
          case Move.colour:
            setColour(move[2], board[move[1]]);
          case Move.centerZero:
            int number = 1;
            for(bool needsUndone in move[2])
            {
              if(needsUndone)setPencilCenter(number, board[move[1]]);
              number += 1;
            }
          case Move.cornerZero:
            int number = 1;
            for(bool needsUndone in move[2])
            {
              if(needsUndone)setPencilCorner(number, board[move[1]]);
              number += 1;
            }
        }
      }
    });
  }

  void boardPlayMode() async
  {
    setState(() {
      boardModePlay = true;
      mode = ButtonMode.number;
      
      clearSelected();
      handleSeen(board[0]);

    });
    boardID = await SaveLoad.saveBoard(boardID, meAsString());

  }

  void boardSetMode() async
  {
    setState(() {
      boardModePlay = false;
      mode = ButtonMode.fixedNum;
      clearSelected();
      handleSameNum(0);
      for (Cell cell in board)
      {
        cell.reset();
      }
    });
    boardID = await SaveLoad.saveBoard(boardID, meAsString());

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
        if (boardModePlay)
        {
        handleSameNum(thisCell.num);
        }
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
      child = FittedBox(
        fit: BoxFit.contain,
        child: Text(
          '${cell.num}',
          style: TextStyle(fontSize: 40, color: cell.textColour)
        ), 
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
              return FittedBox (
                fit: BoxFit.contain,
                child: Text(
                  ' ${i+1} ', 
                  style: TextStyle(fontSize:12, color: Colors.black),
                ),
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
        color: () {
          if (boardModePlay)
          {
            return cell.colour;
          }
          return CellColours.fixed;
        }(),
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

  ElevatedButton inputButton(int number, ButtonMode mode)
  {
    String textVal = "$number";

    Color colour = Colors.white;
    TextStyle textStyle;
    VoidCallback onPressFunction;
    Widget child;
    if (number==0)
    {
      textVal="X";
    }
    switch (mode)
    {
      case ButtonMode.number:
        onPressFunction =()=> 
        {
          if(selected.isNotEmpty)
          {
            undoHistory.add([Move.number, selected[0].index, selected[0].num]),
            setNumber(number, selected[0], false),
          }
        };
        textStyle = TextStyle(color: Colors.black, fontSize: 40);//DefaultTextStyle.of(context).style.apply(fontSizeFactor: 4);
        child = Text(textVal, style: textStyle);
      case ButtonMode.fixedNum:
        onPressFunction =()=> 
        {
          if(selected.isNotEmpty){
            setNumber(number, selected[0], true),
          }
        };
        textStyle = TextStyle(color: const Color.fromARGB(255, 34, 104, 36), fontSize: 40);
        child = FittedBox(
          fit: BoxFit.contain,
          child: Text(textVal, style: textStyle),
          );
      case ButtonMode.colour:
        onPressFunction =()=> 
        {
          if(selected.isNotEmpty)
          {
            undoHistory.add([Move.colour, selected[0].index, selected[0].getColourId()]),
            setColour(number, selected[0]),
          },
        };
        textStyle = TextStyle();
        colour = CellColours.baseColours[number];
        textVal = "";
        child = Text(textVal, style: textStyle);
      case ButtonMode.pencilCenter:
        onPressFunction =()=> 
        {
          if(selected.isNotEmpty)
          {
            number!=0?undoHistory.add([Move.pencilCenter, selected[0].index, number]):
              undoHistory.add([Move.centerZero, selected[0].index, [...selected[0].pencilCenter]]),
            setPencilCenter(number, selected[0]),
          }
        };
        textStyle = TextStyle(fontSize: 20, color: Colors.black,);
        child = Text(textVal, style: textStyle);
      case ButtonMode.pencilCorner:
        textStyle = TextStyle(color: Colors.black);
        onPressFunction =()=> 
        {
          if(selected.isNotEmpty)
          {
            number!=0?undoHistory.add([Move.pencilCorner, selected[0].index, number]):
              undoHistory.add([Move.cornerZero, selected[0].index, [...selected[0].pencilCorner]]),
            setPencilCorner(number, selected[0]),
          }
        };
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
      undoHistory = [];
      for (Cell cell in board)
        {
          clearSelected();
          if (!cell.isFixed)
          {
            cell.num=0;
            cell.pencilCorner = [false, false, false, false, false, false, false, false, false,];
            cell.pencilCenter = [false, false, false, false, false, false, false, false, false,];
          }
          cell.updateColour(0);
          cell.updateTextColour();
        }    
    });
  }

  void resetAll()
  {
    setState(() 
    {
      undoHistory = [];
      for (Cell cell in board)
        {
          cell.unfix();
          cell.pencilCorner = [false, false, false, false, false, false, false, false, false,];
          cell.pencilCenter = [false, false, false, false, false, false, false, false, false,];
          cell.updateColour(0);
        }    
    });
  }

  @override
  void initState()
  {
    super.initState();
    List<String> boardCells = widget.board.split(',');
    boardModePlay = widget.boardModePlay;
    boardID = widget.initBoardID;
    if (boardModePlay)
    {
      mode = ButtonMode.number;
    }
    constraints = widget.constraints;
    name = widget.name;
    if (widget.board=='')
    {
      _populateBoard();
    }
    else
    {
      int i = 0;
      for (String cellString in boardCells)
      {
        List<String> cellData = cellString.split('.');
        Cell newCell = Cell(int.parse(cellData[5]) ,i);
        List<String> centerVals = cellData[2].split('');
        List<String> cornerVals = cellData[3].split('');
        newCell.isFixed = cellData[0]=='0'? false:true;
        newCell.num = int.parse(cellData[1]);
        for (String num in centerVals)
        {
          newCell.pencilCenter[int.parse(num)-1] = true;
        }
        for (String num in cornerVals)
        {
          newCell.pencilCorner[int.parse(num)-1] = true;
        }
        newCell.updateColour(int.parse(cellData[4]));
        newCell.updateTextColour();
        i++;
        board.add(newCell);
      }
    }
    handleMargins(0, true);
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      resizeToAvoidBottomInset : false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage())), 
          icon: Icon(Icons.home)
        ),
        title: TextField( 
          controller: TextEditingController(),
          inputFormatters: [
            FilteringTextInputFormatter.deny('|')
          ],
          maxLength: 20,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          showCursor: false,
          decoration: InputDecoration(
            counterText: '',
            border: InputBorder.none,
            label: Row(children:[
              Text('$name   '),
              Icon(Icons.edit_note)
              ]),
          ),
          onSubmitted: (String value) async
          {
            setState(()
            {
              name = value;
            });
            boardID = await SaveLoad.saveBoard(boardID, meAsString());
          },
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 10,
              children: [
                ElevatedButton( // set mode button | play mode button
                  onPressed: () => boardModePlay? boardSetMode():boardPlayMode(),
                  child: Text(boardModePlay?'Set Mode':'Play Mode'),
                ),
                ElevatedButton( //Undo button
                  onPressed: ()=> _doUndo(), 
                  child: Text('undo')),
                ElevatedButton(
                  onPressed: () => checkSol(),
                  child: const Text('Check'),
                ),
                ElevatedButton(  // reset button
                  onPressed: () => showDialog(
                    context: context, 
                    builder: (context) => AlertDialog(
                      title:  Text(boardModePlay?'Clear Played Input?':'Clear EVERYTHING?'),
                      content:  
                        Text(boardModePlay?'Clears all inputed numbers, pencil marks, colours and undo history. This action cannot be undone.'
                          :'This will empty the board. Everything will be gone, including fixed numbers and undo history.'),
                      actions: [
                        ElevatedButton( 
                          onPressed: () => 
                            { 
                              Navigator.pop(context, 'ClearBoard'),
                              boardModePlay? resetPlay():resetAll(),
                            },
                          child: Text('Yes')
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'), 
                          child: Text('No'))
                      ],
                    )
                  ),
                  child: const Text('reset'),
                ),
                ElevatedButton( //hints button
                  onPressed: ()
                  {
                    for (Cell cell in board)
                    {
                      cell.possibleVals= Sudoku.getPossibilities(board, cell);
                    }

                    List<Hint> hints = Sudoku.getHints(board);
                    int hintIndex = -1;
                    String nextText = hints.isEmpty?'Close':'Show Hints';

                    showDialog(
                      context: context, 
                      builder: (context)  
                      {
                        if (hintIndex>=0)
                        {
                          for(int index in hints[hintIndex].cellIds)
                          {
                            board[index].hint();
                          }
                        }
                        return StatefulBuilder(
                          builder: (context, setAlertState)
                          {
                            return AlertDialog(
                              title: Text('Hint!'),
                              content: Text(hints.isEmpty?'Couldnt find any hints!':
                                            hintIndex==-1?'You are about to look at some hints, are you sure you want to admit defeat?':
                                            hints[hintIndex].text),
                              actions: [
                                ElevatedButton(
                                  onPressed: () => 
                                    { 
                                      Navigator.pop(context, 'CloseHints'),
                                      
                                      if (hintIndex>-1)
                                      for (int index in hints[hintIndex].cellIds)
                                      {
                                        board[index].unHint(),
                                      }
                                      
                                    },
                                  child: Text(hintIndex==-1?'Keep Trying':'Ok')
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                  {
                                    if (hints.isEmpty)
                                    {
                                      Navigator.pop(context, 'close')
                                    }
                                    else if(hintIndex==hints.length-1)
                                    {
                                      setState((){
                                        for (int index in hints[hintIndex].cellIds)
                                        {
                                          board[index].unHint();
                                        }
                                      }),
                                      Navigator.pop(context, 'close')
                                    }
                                    else
                                    {
                                      setAlertState(()
                                      {
                                        setState(() {
                                          if(hintIndex==-1)
                                          {
                                              clearSelected();
                                              handleSeen(board[0]);
                                          }
                                          if(hintIndex>-1)
                                          {
                                            for (int index in hints[hintIndex].cellIds)
                                            {
                                              board[index].unHint();
                                            }
                                          }
                                          hintIndex+=1;
                                          nextText = hintIndex==hints.length-1? 'Close':'Next Hint';
                                          if (!hints.isEmpty)
                                          {
                                            for (int index in hints[hintIndex].cellIds)
                                            {
                                              board[index].hint();
                                            } 
                                          }
                                        });
                                      }), 
                                    }
                                  },
                                  child: Text(nextText)
                                ),
                              ],
                            );
                          }
                        );
                      }
                    );
                  },
                  child: Text('Hints Pls'),
                ),
              ] 
            ),
          ),
          Container(
            margin: const EdgeInsets.all(5),
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
                  color: cell.marginColour,
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
                    onPressed: (){
                      if(boardModePlay)
                      {
                        return () => setMode(ButtonMode.number);
                      }
                      return () => setMode(ButtonMode.fixedNum);
                      }(), 
                    child: Text('Numbers')
                  ),
                  (){
                    if (boardModePlay)
                    {
                      return ElevatedButton(
                        onPressed: () => setMode(ButtonMode.pencilCorner), 
                        child: Image.asset('assets/PencilCorner.png'),
                      );
                    }
                    return Container();
                  }(),
                  (){
                    if (boardModePlay)
                    {
                      return ElevatedButton(
                        onPressed: () => setMode(ButtonMode.pencilCenter), 
                        child: Text('Center')
                      );
                    }
                    return Container();
                  }(),
                  (){
                    if (boardModePlay)
                    {
                      return ElevatedButton(
                        onPressed: () => setMode(ButtonMode.colour), 
                        child: Text('Colour')
                      );
                  }
                    return Container();
                  }(),
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
                  return inputButton(number, mode);
                }
              ),
            ],
          ),
        ],
      ),
    );
  }
}