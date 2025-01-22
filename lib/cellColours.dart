import 'package:flutter/material.dart';

class CellColours 
{
  CellColours._();

  static List<Color> baseColours = [
                         Color.fromARGB(255, 184, 251, 249),
                         Colors.blue, 
                         Colors.red, 
                         Colors.cyan, 
                         Colors.green, 
                         Colors.pinkAccent, 
                         Colors.purple, 
                         Colors.brown, 
                         Colors.orange, 
                         Colors.grey];
  static Color setMode = const Color.fromARGB(255, 137, 255, 133);
  static Color sameNumText = const Color.fromARGB(255, 76, 173, 185);
  static Color fixedText = const Color.fromARGB(255, 0, 124, 4);
  static Color baseText = Colors.black;
  static Color seenHighlighter = const Color.fromARGB(66, 162, 161, 162);
  static Color selectedHighlighter = const Color.fromARGB(213, 255, 235, 59);
  static Color baseMargin = Colors.black;
  static Color hintMargin = const Color.fromARGB(255, 15, 227, 255);
  static Color hinted = const Color.fromARGB(255, 255, 15, 223);

static Color getNewColour({int baseId=0, bool selected=false, bool seen=false, bool isSetMode=false, bool hinting=false})
  {
    Color newColour = isSetMode? setMode:
                      hinting? hinted:
                      baseColours[baseId];
    if (selected)
    {
      newColour = Color.alphaBlend(selectedHighlighter, newColour);
    }
    if (seen)
    {
      newColour = Color.alphaBlend(seenHighlighter, newColour);
    }
    return newColour;
  }

static Color getMarginColour({int? boxId})
{
  if(boxId != null)
  {
    return baseColours[boxId];
  }
  else{
    return baseMargin;
  }
}

static Color getTextColour({bool? isSame, bool? isFixed, int? boxId})
  {
    if(boxId!=null)
    {
      return baseColours[boxId];
    }
    if(isSame!=null)
    {
      if(isSame)return sameNumText;
    }
    if(isFixed!=null)
    {
      if(isFixed)return fixedText;
    }
    return baseText;
  }
}