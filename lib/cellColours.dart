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
  static Color sameNumText = Colors.green;
  static Color seenHighlighter = const Color.fromARGB(66, 162, 161, 162);
  static Color text = Colors.black;
  static Color selectedMargin = Colors.yellow;
  static Color selectedHighlighter = const Color.fromARGB(213, 255, 235, 59);
  static Color notSelectedMargin = Colors.black;



static Color getNewColour(int baseID, bool isSelected, bool seen)
  {
    Color newColour = baseColours[baseID];
    if (isSelected)
    {
      newColour = Color.alphaBlend(selectedHighlighter, newColour);
    }
    if (seen)
    {
      newColour = Color.alphaBlend(seenHighlighter, newColour);
    }
    return newColour;
  }
  static Color getTextColour(bool same)
  {
    if (same)
    {
      return sameNumText;
    }
    else
    {
      return text;
    }
  }
  
}