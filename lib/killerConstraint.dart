import 'package:sudoku_notepad/constraint.dart';
import 'package:sudoku_notepad/sudoku.dart';
import 'package:sudoku_notepad/variant.dart';

class KillerConstraint extends Constraint
{
  int sum;
  @override

  KillerConstraint(super.appliesToIndexes, this.sum);

  @override
  Variant? get type
  {
    return Variant.killer;
  }

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