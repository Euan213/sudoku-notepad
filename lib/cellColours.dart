import 'package:flutter/material.dart';

class CellColours 
{
  CellColours._();

  static Color base = const Color.fromARGB(255, 251, 228, 184);
  static Color sameNumHighlighter = Colors.green;
  static Color seenHighlighter = const Color.fromARGB(72, 162, 161, 162);
  static Color text = Colors.black;
  static Color selected = Colors.yellow;

  static Color getNewColour(bool isSelected, bool same, bool seen)
  {
    if (isSelected)
    {
      return selected;
    }

    Color newColour = base;
    if (same)
    {
      newColour = Color.alphaBlend(sameNumHighlighter, newColour);
    }
    if (seen)
    {
      newColour = Color.alphaBlend(seenHighlighter, newColour);
    }
    return newColour;
  }
  
}