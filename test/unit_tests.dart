import 'dart:collection';
import 'dart:io';
import 'dart:convert';
import 'package:sudoku_notepad/cell.dart';
import 'package:sudoku_notepad/sudoku.dart';


void checkSolve()
{
  Cell cell;
  List<Cell> board;
  List<int> solved_easy_to_evil = [0,0,0,0,0];
  HashMap<int, int> emptiesSolved = HashMap();
  HashMap<int, int> emptiesUnsolved = HashMap();
  int empties;
  int solvedAvgTimes;
  int unsolvedAvgTimes;
  int avgTimes;
  int total;
  Stopwatch stopwatch = new Stopwatch();
  int time;
  for(int d=0; d<=4; d++)
  {
    print('testing on difficulty $d');
    var text = File('test/data/$d.json').readAsStringSync();
    var map = jsonDecode(text);
    total = map['puzzles'].length;
    avgTimes = 0;
    solvedAvgTimes = 0;
    unsolvedAvgTimes = 0;
    for(var p in map['puzzles'])
    {
      empties = 0;
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
        else
        {
          empties += 1;
        }
        board.add(cell);
      }
      stopwatch.reset();
      stopwatch.start();
      var outcome = Sudoku.logicalSolve(board, []);
      time = stopwatch.elapsedMilliseconds;
      stopwatch.stop();
      if(outcome==SolveOutcome.success)
      {
        solved_easy_to_evil[d]++;
        solvedAvgTimes += time;
        emptiesSolved[empties]==null? emptiesSolved[empties]=1 : emptiesSolved[empties]= emptiesSolved[empties] !+ 1;
      }
      else
      {
        unsolvedAvgTimes += time;
        emptiesUnsolved[empties]==null? emptiesUnsolved[empties]=1 : emptiesUnsolved[empties]= emptiesUnsolved[empties] !+ 1;
      }
      avgTimes += time;
      

    }
    print('difficulty rating: $d. This took ${avgTimes/total} milliseconds on average per puzzle');
    print('it took ${solvedAvgTimes/solved_easy_to_evil[d]} per completed puzzle, on average and ${unsolvedAvgTimes/(total-solved_easy_to_evil[d])} for unsolved puzzles');
    print('solved ${solved_easy_to_evil[d]} out of $total puzzles');



  }
  print('solved based on missing digits');
  print(emptiesSolved);
  print('unsolved based on missing digits');
  print(emptiesUnsolved);
}

void main() {
  checkSolve();
}
//.8...97.5.453.8...3.6257.41.381....7..7.3...8...7..5639..5.418.6....3..48.4.71...