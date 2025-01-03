import 'package:flutter/material.dart';

class CellColours 
{
  CellColours._();

  static List<Color> baseColours = [
                         Color.fromARGB(255, 251, 228, 184),
                         Colors.blue, 
                         Colors.red, 
                         Colors.yellow, 
                         Colors.green, 
                         Colors.pink, 
                         Colors.purple, 
                         Colors.brown, 
                         Colors.orange, 
                         Colors.grey];
  static Color base = const Color.fromARGB(255, 251, 228, 184);
  static Color sameNumText = const Color.fromARGB(255, 76, 173, 185);
  static Color fixedText = const Color.fromARGB(255, 1, 112, 5);
  static Color baseText = Colors.black;
  static Color seenHighlighter = const Color.fromARGB(66, 162, 161, 162);
  static Color selectedMargin = Colors.yellow;
  static Color selectedHighlighter = const Color.fromARGB(213, 255, 235, 59);
  static Color notSelectedMargin = Colors.black;



static Color getNewColour(int baseID, bool selected, bool seen)
  {
    Color newColour = baseColours[baseID];
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
  static Color getTextColour(bool selected, bool same, bool fixed)
  {
    if (fixed)
    {
      return fixedText;
    }
    if (same && !selected)
    {
      return sameNumText;
    }
    return baseText;
  }
  
}