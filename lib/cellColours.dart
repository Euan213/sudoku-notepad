import 'package:flutter/material.dart';

class CellColours 
{
  CellColours._();

  static Color base = const Color.fromARGB(255, 251, 228, 184);
  static Color sameNumText = Colors.green;
  static Color seenHighlighter = const Color.fromARGB(29, 162, 161, 162);
  static Color text = Colors.black;
  static Color selected = Colors.yellow;

  static Color getNewColour(bool isSelected, bool seen)
  {
    if (isSelected)
    {
      return selected;
    }

    Color newColour = base;
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