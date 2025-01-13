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
import 'package:sudoku_notepad/variant.dart';


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
  DateTime lastSave = DateTime.now();

  List<Cell> board = [];
  late bool boardModePlay;
  List<dynamic> constraints = [];

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
    List<String> cells = [];
    List<String> constraintsStr = [];
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
      cells.add('${cell.isFixed?1:0}.${cell.num}.$centerStr.$cornerStr.${cell.getColourId()}.${cell.boxId}');
    }
    if(constraints[0]!='')
    {
      print(''.split('¦').length);
      print(constraints.length);
      for(var constraint in constraints)
      {
        print(constraint);
        switch(constraint[0]) //the way a constraint is converted to a string is different for each variant type
        {
          case Variant.killer:
            constraintsStr.add('${constraint[0].name}${constraint[1].join('.')}${constraint[2]}');
          default:
            continue;
        }
      }
    }
    return "${constraintsStr.join('¦')}|${boardModePlay?1:0}|${cells.join(',')}|$name";
  }

  void setMode(ButtonMode m)
  {
    setState(()
    {
      mode = m;
    });
  }

  List<Cell> _getNeighborsFromIndexes(List<int> indexes, Cell cell)
  {
    List<Cell> neighbors = [];
    for (int index in indexes)
    {
      if (index == -1)
      {
        neighbors.add(cell); //maintain error value to maintain position of each neighbor in list
      }
      else{
        neighbors.add(board[index]);
      }
    }
    return neighbors;
  }

  void handleMargins(List<Cell> cells)
  {
    List<Cell> neighbors;
    for(Cell cell in cells)
    {
      neighbors = _getNeighborsFromIndexes(Sudoku.getNeighbors(cell), cell);
      cell.updateMargins(neighbors);
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
  
  void setNumber(int n, Cell cell, bool fixed)
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
  }

  void setPencilCorner(int n, Cell cell)
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
  }
  
  void setPencilCenter(int n, Cell cell)
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
  }
  
  void setColour(int n, Cell cell)
  {
    setState(() {
      cell.updateColour(n);
    });
  }

  void _setBoxId(int boxId)
  {
    setState(() {
      if(selected.isNotEmpty)
      {
        for(Cell cell in selected)
        {
          cell.boxId = boxId;
          handleMargins(_getNeighborsFromIndexes(Sudoku.getNeighbors(cell),cell));
          handleMargins([cell]);
        }
      }
    });
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

  void boardPlayMode()
  {
    setState(() {
      boardModePlay = true;
      mode = ButtonMode.number;
      
      clearSelected();
      handleSeen(board[0]);

    });
  }

  void boardSetMode()
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

  Widget _varientOverlay(Cell cell)
  {
    Widget Vdisplay = Container();
    
    return Vdisplay;
  }

  Widget cellDisplay(Cell cell)
  {
    Widget child;
    Alignment alignment;
    if(mode == ButtonMode.jigsaw)
    {
      cell.marginColour = CellColours.baseColours[cell.boxId];
      alignment = Alignment.center;
      child = FittedBox(
        fit: BoxFit.contain,
        child: Text(
          String.fromCharCode(cell.boxId+65),
          style: TextStyle(fontSize: 40, color: CellColours.baseColours[cell.boxId])
        ), 
      );
    }else
    {
      cell.marginColour = CellColours.notSelectedMargin;
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
    }
    if(cell.selected)cell.marginColour=CellColours.selectedMargin;
    return Stack(
      children: [
        Container(
          color: cell.marginColour,
          child: InkWell(
            onTap: () => select(cell),
            child: Container(
              alignment: alignment,
              color: () {
                if (boardModePlay)
                {
                  return cell.colour;
                }
                return CellColours.setMode;
              }(),
              margin: EdgeInsets.only(
                left: cell.leftMargin,
                right: cell.rightMargin,
                top: cell.topMargin,
                bottom: cell.bottomMargin,
              ),
              child: child,
            )
          ),
        ),
        _varientOverlay(cell),
      ],
    );
  }

  List<Widget> _getInputModeButtons()
  {
    List<Widget> inputModeButtons = [];
    inputModeButtons.add(ElevatedButton( //number input mode button
      onPressed: ()
      {
        boardModePlay?setMode(ButtonMode.number):setMode(ButtonMode.fixedNum);
      },
      child: Text('Numbers')
    ));
    if(boardModePlay)
    {
      inputModeButtons.add(ElevatedButton( // center pencil marks input mode button
        onPressed: () => setMode(ButtonMode.pencilCenter), 
        child: Text('Center')
      ));
      inputModeButtons.add(ElevatedButton( //corner pencil marks input mode button
        onPressed: () => setMode(ButtonMode.pencilCorner), 
        child: Image.asset('assets/PencilCorner.png'),
      ));
      inputModeButtons.add(ElevatedButton( // colour input mode button
        onPressed: () => setMode(ButtonMode.colour), 
        child: Text('Colour')
      ));
    }else{
      inputModeButtons.add(ElevatedButton( // boxID input mode button
        onPressed: () => setMode(ButtonMode.jigsaw), 
        child: Text('Set Jigsaw')
      ));
    }
    return inputModeButtons;
  }

  Widget _jigsawModeInputZone()
  {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.all(Radius.circular(20)), 
      ),
      child: GridView.builder(
        padding: EdgeInsets.all(5),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10
        ),
        itemBuilder: (context, sector)
        {
          if(sector==0)
          {
            return Container(
              alignment: Alignment.center,
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9,
                itemBuilder: (context, number) 
                {
                  int boxContains = Sudoku.getNumberOfCellsInBox(number, board);
                  return Container(
                    alignment: Alignment.center,
                    color: boxContains==9? const Color.fromARGB(255, 187, 255, 189):const Color.fromARGB(255, 255, 173, 167),
                    child: Text('box ${String.fromCharCode(number+65)} contains $boxContains cells'),
                  );
                }
              ),
              
            );
          }
         return DecoratedBox(
            decoration: const BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.all(Radius.circular(20)), 
            ),
            child: Column(
              children: [
                Container
                (
                  alignment: Alignment.topCenter,
                  child: Text('Configure Box Shapes'),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    right: 15,
                    left: 15,
                  ),
                  itemCount: 9,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ), 
                  itemBuilder: (context, boxId)
                  {
                    return ElevatedButton(
                      onPressed: ()
                      {
                        _setBoxId(boxId);
                      }, 
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: const Color.fromARGB(255, 255, 248, 183),
                      ),
                      child:Container(
                        alignment: Alignment.center,
                        child: Text(String.fromCharCode(boxId+65)),
                      ),
                      
                    );
                  }
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _boardInputZone()
  {
    Widget zone;
    switch(mode)
    {
      case ButtonMode.jigsaw:
        zone = _jigsawModeInputZone();
      default:
        zone = GridView.builder(
          shrinkWrap: true,
          itemCount:10,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
          itemBuilder:(context, number)
          {
            return _zeroToNineButton(number);
          }
        );
    }
    return zone;
  }

  ElevatedButton _zeroToNineButton(int number)
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
      default:
        throw 'unimplemented case for boardMode value'; 
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

  void _doSave() async
  {
    DateTime now = DateTime.now();
    int difference = now.difference(lastSave).inSeconds;
    if(difference >= 5)
    {
      lastSave = now;
      boardID = await SaveLoad.saveBoard(boardID, meAsString());
    }
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
      List<String> cellData;
      Cell newCell;
      List<String> centerVals;
      List<String> cornerVals;
      int i = 0;
      for (String cellString in boardCells)
      {
        cellData = cellString.split('.');
        newCell = Cell(int.parse(cellData[5]) ,i);
        centerVals = cellData[2].split('');
        cornerVals = cellData[3].split('');
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
    handleMargins(board);
    if(widget.constraints.isNotEmpty)
    {
      Variant v;
      List<int> cells;
      List<String> groupingData;
      for(String grouping in widget.constraints)
      {
        cells = [];
        groupingData = grouping.split(',');
        try //load variants constraints from save
        {
          v = Variant.values.byName(groupingData[0]);
          for(String index in groupingData[1].split('.'))
          {
            cells.add(int.parse(index));
          }
          switch(v) //since additional data types/amounts can vary on the variant it much be dealt with in the context of the variant it applies to.
          {
            case Variant.killer:
              int sum = int.parse(groupingData[2]);
              constraints.add([v, cells, sum]);
          }
        }catch (e) //skip entries that cant be read, prevents a crash on bad data
        { 
          continue;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context)
  {
    _doSave();
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
          onSubmitted: (String value)
          {
            setState(()
            {
              name = value;
            });
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
                return cellDisplay(cell);
              },
            ),
          ),
          Row(children: _getInputModeButtons(),),
          _boardInputZone(),
        ],
      ),
    );
  }
}