import 'package:flutter/material.dart';

class CellColours 
{
  CellColours._();

  static List<Color> baseColours = [
                         const Color.fromARGB(255, 199, 255, 253),
                         const Color.fromARGB(255, 140, 203, 255), 
                         const Color.fromARGB(255, 255, 157, 150), 
                         const Color.fromARGB(255, 214, 255, 138), 
                         const Color.fromARGB(255, 171, 255, 174), 
                         const Color.fromARGB(255, 138, 255, 245), 
                         const Color.fromARGB(255, 241, 158, 255), 
                         const Color.fromARGB(255, 192, 149, 133), 
                         const Color.fromARGB(255, 255, 207, 134), 
                         const Color.fromARGB(255, 199, 199, 199)];
  static Color setMode = const Color.fromARGB(255, 167, 255, 164);
  static Color sameNumText = const Color.fromARGB(255, 255, 56, 195);
  static Color error = Colors.red;
  static Color fixedText = const Color.fromARGB(255, 0, 124, 4);
  static Color base = Colors.black;
  static Color seenHighlighter = const Color.fromARGB(66, 162, 161, 162);
  static Color selectedHighlighter = const Color.fromARGB(213, 255, 235, 59);
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
    return base;
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
    return base;
  }
}