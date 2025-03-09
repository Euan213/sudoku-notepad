import 'dart:io';
import 'dart:convert';
import 'package:sudoku_notepad/cell.dart';
import 'package:sudoku_notepad/sudoku.dart';


void checkSolve()
{
  Cell cell;
  List<Cell> board;
  List<int> solved_easy_to_evil = [0,0,0,0,0];
  int total;
  for(int d=4; d<=4; d++)
  {
    print('testing on difficulty $d');
    var text = File('test/data/$d.json').readAsStringSync();
    var map = jsonDecode(text);
    total = map['puzzles'].length;
    for(var p in map['puzzles'])
    {
      board = [];
      var puzzle = p['puzzle'];
      List<dynamic> splt = puzzle.split('');
      for(final (i, n) in splt.indexed)
      {
        cell = Cell(Sudoku.getClassicBoxIdFromIndex(i), i);
        if(n!='.')
        {
          cell.num = int.parse(n);
        }
        board.add(cell);
      }
      var outcome = Sudoku.logicalSolve(board, []);
      if(outcome==SolveOutcome.success)
      {
        solved_easy_to_evil[d]++;
        print(puzzle);
      }
      else{
        
      }

    }
    print('difficulty rating: $d');
    print('solved ${solved_easy_to_evil[d]} out of $total puzzles');
    break;
  }
}

void main() {
  checkSolve();
}
//.8...97.5.453.8...3.6257.41.381....7..7.3...8...7..5639..5.418.6....3..48.4.71...