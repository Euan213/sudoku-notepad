import 'package:sudoku_notepad/constraint.dart';
import 'package:sudoku_notepad/sudoku.dart';

class KillerConstraint extends Constraint
{
  int sum;
  KillerConstraint(super.type, super.appliesToIndexes, this.sum);

  @override
  CheckSolOutcome? checkMe(List<int> nums) 
  {
    int realSum = 0;
    for(int num in nums)
    {
      if(nums.toSet().length != nums.length)
      {
        return CheckSolOutcome.killerExclusivityViolated;
      }
      realSum+=num;
      if(realSum > sum && sum!=0)
      {
        return CheckSolOutcome.killerSumViolated;
      }
    }
    return null;
  }
}