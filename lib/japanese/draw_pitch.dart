import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:immersion_reader/japanese/utils.dart';

String pitchValueToPatt(String word, int pitchValue) {
  int numberOfMora = HiraToMora(word).length;
  if (numberOfMora >= 1) {
    if (pitchValue == 0) {
      // heiban
      return 'L${'H' * numberOfMora}';
    } else if (pitchValue == 1) {
      // atamadaka
      return 'H${'L' * numberOfMora}';
    } else if (pitchValue >= 2) {
      int stepdown = pitchValue - 2;
      return 'LH${'H' * stepdown}${'L' * (numberOfMora - pitchValue + 1)}';
    }
  }
  return '';
}

String pitchSvg(String word, String patt, {bool silent = false}) {
  /* Draw pitch accent patterns in SVG

    Examples:
        はし HLL (箸)
        はし LHL (橋)
        はし LHH (端)
        */
  List<String> mora = HiraToMora(word);
  if ((patt.length - mora.length != 1) && !silent) {
    debugPrint('pattern should be number of morae + 1. got $word, $patt');
  }
  int positions = max(mora.length, patt.length);
  const int stepWidth = 35;
  const int marginLr = 16;
  int svgWidth = max(0, ((positions - 1) * stepWidth) + (marginLr * 2));
  String svg =
      '<svg xmlns="http://www.w3.org/2000/svg" width="${svgWidth}px" height="75px" viewBox="0 0 $svgWidth 75'
      '">';
  String chars = '';
  for (int i = 0; i < mora.length; i++) {
    int xCenter = marginLr + (i * stepWidth);
    chars += _text(xCenter - 11, mora[i]);
  }
  String circles = '';
  String paths = '';
  String pathTyp = '';
  List<int> prevCenter = [-1, -1];
  for (int i = 0; i < patt.length; i++) {
    int xCenter = marginLr + (i * stepWidth);
    String accent = patt[i];
    int yCenter = 0;
    if (['H', 'h', '1', '2'].contains(accent)) {
      yCenter = 5;
    } else if (['L', 'l', '0'].contains(accent)) {
      yCenter = 30;
    }
    circles += _circle(xCenter, yCenter, o: i >= mora.length);
    if (i > 0) {
      if (prevCenter[1] == yCenter) {
        pathTyp = 's';
      } else if (prevCenter[1] < yCenter) {
        pathTyp = 'd';
      } else if (prevCenter[1] > yCenter) {
        pathTyp = 'u';
      }
      paths += _path(prevCenter[0], prevCenter[1], pathTyp, stepWidth);
    }
    prevCenter = [xCenter, yCenter];
  }
  svg += chars;
  svg += paths;
  svg += circles;
  svg += '</svg>';
  return svg;
}

String _circle(int x, int y, {bool o = false}) {
  String r = '<circle r="5" cx="$x" cy="$y" style="opacity:1;fill:#000;" />';
  if (o) {
    r += '<circle r="3.25" cx="$x" cy="$y" style="opacity:1;fill:#fff;"'
        '/>';
  }
  return r;
}

String _text(int x, String mora) {
  if (mora.length == 1) {
    return '<text x="$x" y="67.5" style="font-size:20px;font-family:sans-'
        'serif;fill:#000;">$mora</text>';
  } else {
    return '<text x="${x - 5}" y="67.5" style="font-size:20px;font-family:sans-'
        'serif;fill:#000;">${mora[0]}</text><text x="${x + 12}" y="67.5" style="font-'
        'size:14px;font-family:sans-serif;fill:#000;">${mora[1]}</text>';
  }
}

String _path(int x, int y, String typ, int stepWidth) {
  String delta = '';
  switch (typ) {
    case 's':
      delta = '$stepWidth,0';
      break;
    case 'u':
      delta = '$stepWidth,-25';
      break;
    case 'd':
      delta = '$stepWidth,25';
      break;
  }
  return '<path d="m $x,$y $delta" style="fill:none;stroke:#000;stroke-width'
      ':1.5;" />';
}
