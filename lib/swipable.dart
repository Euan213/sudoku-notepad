import 'package:flutter/material.dart';

class Swipable extends StatefulWidget{

  @override
  State<Swipable> createState() => _SwipableState();
}

class _SwipableState extends State<Swipable>{
  @override
  Widget build(BuildContext context) 
  {
    return SizedBox(
      height: 100,
      width: 100,
      child: Container(
        color: Colors.red,
        child: GestureDetector(
          // onPanStart: ,
          // onPanEnd: ,
          onPanUpdate: (d) {
            print("swipe detected");
          },
        ),
      ),
    );
  }

}