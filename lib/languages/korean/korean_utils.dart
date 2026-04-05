class KoreanUtils {
  // ported from Hangul.js
  // https://github.com/e-/Hangul.js
  static const int hangulOffset = 0xAC00;

  static const List<String> choList = [
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ];

  static const List<dynamic> jungList = [
    'ㅏ',
    'ㅐ',
    'ㅑ',
    'ㅒ',
    'ㅓ',
    'ㅔ',
    'ㅕ',
    'ㅖ',
    'ㅗ',
    ['ㅗ', 'ㅏ'],
    ['ㅗ', 'ㅐ'],
    ['ㅗ', 'ㅣ'],
    'ㅛ',
    'ㅜ',
    ['ㅜ', 'ㅓ'],
    ['ㅜ', 'ㅔ'],
    ['ㅜ', 'ㅣ'],
    'ㅠ',
    'ㅡ',
    ['ㅡ', 'ㅣ'],
    'ㅣ',
  ];

  static const List<dynamic> jongList = [
    '',
    'ㄱ',
    'ㄲ',
    ['ㄱ', 'ㅅ'],
    'ㄴ',
    ['ㄴ', 'ㅈ'],
    ['ㄴ', 'ㅎ'],
    'ㄷ',
    'ㄹ',
    ['ㄹ', 'ㄱ'],
    ['ㄹ', 'ㅁ'],
    ['ㄹ', 'ㅂ'],
    ['ㄹ', 'ㅅ'],
    ['ㄹ', 'ㅌ'],
    ['ㄹ', 'ㅍ'],
    ['ㄹ', 'ㅎ'],
    'ㅁ',
    'ㅂ',
    ['ㅂ', 'ㅅ'],
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ];

  static bool _isHangul(int code) {
    return 0xAC00 <= code && code <= 0xD7A3;
  }

  static List<String> _disassemble(String input) {
    final List<String> result = [];

    for (int i = 0; i < input.length; i++) {
      final int code = input.codeUnitAt(i);

      if (_isHangul(code)) {
        int tempCode = code - hangulOffset;

        int jong = tempCode % 28;
        int jung = ((tempCode - jong) ~/ 28) % 21;
        int cho = ((tempCode - jong) ~/ 28) ~/ 21;

        // 초성
        result.add(choList[cho]);

        // 중성
        var jungValue = jungList[jung];
        if (jungValue is List) {
          result.addAll(jungValue.cast<String>());
        } else {
          result.add(jungValue as String);
        }

        // 종성
        if (jong > 0) {
          var jongValue = jongList[jong];
          if (jongValue is List) {
            result.addAll(jongValue.cast<String>());
          } else {
            result.add(jongValue as String);
          }
        }
      } else {
        // non-hangul 그대로
        result.add(String.fromCharCode(code));
      }
    }

    return result;
  }

  static String disassembleToString(String str) {
    if (str.isEmpty) return '';
    return _disassemble(str).join();
  }

  static Map<int, int> _makeHash(List<String> array) {
    final map = <int, int>{};
    for (int i = 0; i < array.length; i++) {
      if (array[i].isEmpty) continue;
      map[array[i].codeUnitAt(0)] = i;
    }
    return map;
  }

  static final Map<int, int> choHash = _makeHash([
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ]);

  static final Map<int, int> jungHash = _makeHash([
    'ㅏ',
    'ㅐ',
    'ㅑ',
    'ㅒ',
    'ㅓ',
    'ㅔ',
    'ㅕ',
    'ㅖ',
    'ㅗ',
    'ㅘ',
    'ㅙ',
    'ㅚ',
    'ㅛ',
    'ㅜ',
    'ㅝ',
    'ㅞ',
    'ㅟ',
    'ㅠ',
    'ㅡ',
    'ㅢ',
    'ㅣ',
  ]);

  static final Map<int, int> jongHash = _makeHash([
    '',
    'ㄱ',
    'ㄲ',
    'ㄳ',
    'ㄴ',
    'ㄵ',
    'ㄶ',
    'ㄷ',
    'ㄹ',
    'ㄺ',
    'ㄻ',
    'ㄼ',
    'ㄽ',
    'ㄾ',
    'ㄿ',
    'ㅀ',
    'ㅁ',
    'ㅂ',
    'ㅄ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ]);

  static bool _isCho(int c) => choHash.containsKey(c);
  static bool _isJung(int c) => jungHash.containsKey(c);
  static bool _isJong(int c) => jongHash.containsKey(c);

  static const complexConsonants = [
    ['ㄱ', 'ㅅ', 'ㄳ'],
    ['ㄴ', 'ㅈ', 'ㄵ'],
    ['ㄴ', 'ㅎ', 'ㄶ'],
    ['ㄹ', 'ㄱ', 'ㄺ'],
    ['ㄹ', 'ㅁ', 'ㄻ'],
    ['ㄹ', 'ㅂ', 'ㄼ'],
    ['ㄹ', 'ㅅ', 'ㄽ'],
    ['ㄹ', 'ㅌ', 'ㄾ'],
    ['ㄹ', 'ㅍ', 'ㄿ'],
    ['ㄹ', 'ㅎ', 'ㅀ'],
    ['ㅂ', 'ㅅ', 'ㅄ'],
  ];

  static const complexVowels = [
    ['ㅗ', 'ㅏ', 'ㅘ'],
    ['ㅗ', 'ㅐ', 'ㅙ'],
    ['ㅗ', 'ㅣ', 'ㅚ'],
    ['ㅜ', 'ㅓ', 'ㅝ'],
    ['ㅜ', 'ㅔ', 'ㅞ'],
    ['ㅜ', 'ㅣ', 'ㅟ'],
    ['ㅡ', 'ㅣ', 'ㅢ'],
  ];

  static Map<int, Map<int, int>> _makeComplexHash(List<List<String>> array) {
    final map = <int, Map<int, int>>{};
    for (var item in array) {
      int a = item[0].codeUnitAt(0);
      int b = item[1].codeUnitAt(0);
      int c = item[2].codeUnitAt(0);

      map.putIfAbsent(a, () => {});
      map[a]![b] = c;
    }
    return map;
  }

  static final complexConsonantsHash = _makeComplexHash(complexConsonants);
  static final complexVowelsHash = _makeComplexHash(complexVowels);

  static int? _isJongJoinable(int a, int b) => complexConsonantsHash[a]?[b];

  static int? _isJungJoinable(int a, int b) => complexVowelsHash[a]?[b];

  static String assembleFromString(String input) {
    if (input.isEmpty) return '';

    // Step 1: disassemble into jamo list
    final List<String> jamo = _disassemble(input);

    // Step 2: re-assemble
    return _assembleFromArray(jamo);
  }

  static String _assembleFromArray(List<String> array) {
    final result = <String>[];

    int stage = 0;
    int completeIndex = -1;
    int? previousCode;
    bool jongJoined = false;

    void makeHangul(int index) {
      if (completeIndex + 1 > index) return;

      int step = 1;
      // int? cho, jung1, jung2, jong1 = 0, jong2;
      int? cho, jung1, jung2, jong1, jong2;
      String hangul = '';

      jongJoined = false;

      while (true) {
        if (step == 1) {
          cho = array[completeIndex + step].codeUnitAt(0);

          if (_isJung(cho)) {
            if (completeIndex + step + 1 <= index) {
              jung1 = array[completeIndex + step + 1].codeUnitAt(0);
              final joined = _isJungJoinable(cho, jung1);
              if (joined != null) {
                result.add(String.fromCharCode(joined));
                completeIndex = index;
                return;
              }
            }
            result.add(array[completeIndex + step]);
            completeIndex = index;
            return;
          } else if (!_isCho(cho)) {
            result.add(array[completeIndex + step]);
            completeIndex = index;
            return;
          }

          hangul = array[completeIndex + step];
        } else if (step == 2) {
          jung1 = array[completeIndex + step].codeUnitAt(0);

          if (_isCho(jung1)) {
            final joined = _isJongJoinable(cho!, jung1);
            if (joined != null) {
              result.add(String.fromCharCode(joined));
              completeIndex = index;
              return;
            }
          } else {
            final choIndex = choHash[cho];
            final jungIndex = jungHash[jung1];
            final jongIndex = jong1 != null ? jongHash[jong1] ?? 0 : 0;

            if (choIndex == null || jungIndex == null) {
              return; // or fallback
            }

            hangul = String.fromCharCode(
              (choIndex * 21 + jungIndex) * 28 + jongIndex + 0xAC00,
            );

            // hangul = String.fromCharCode(
            //   (choIndex * 21 + jungIndex) * 28 + jongIndex + 0xAC00,
            // );
          }
        } else if (step == 3) {
          jung2 = array[completeIndex + step].codeUnitAt(0);

          final joined = _isJungJoinable(jung1!, jung2);
          if (joined != null) {
            jung1 = joined;
          } else {
            jong1 = jung2;
          }

          final choIndex = choHash[cho];
          final jungIndex = jungHash[jung1];
          final jongIndex = jong1 != null ? jongHash[jong1] ?? 0 : 0;

          if (choIndex == null || jungIndex == null) {
            return; // or fallback
          }

          hangul = String.fromCharCode(
            (choIndex * 21 + jungIndex) * 28 + jongIndex + 0xAC00,
          );

          // hangul = String.fromCharCode(
          //   (choHash[cho]! * 21 + jungHash[jung1]!) * 28 + jongIndex + 0xAC00,
          // );
        } else if (step == 4) {
          jong2 = array[completeIndex + step].codeUnitAt(0);

          // final joined = _isJongJoinable(jong1!, jong2);
          // if (joined != null) {
          //   jong1 = joined;
          // } else {
          //   jong1 = jong2;
          // }

          if (jong1 != null) {
            final joined = _isJongJoinable(jong1, jong2);
            if (joined != null) {
              jong1 = joined;
            } else {
              jong1 = jong2;
            }
          } else {
            // No previous jong → just assign
            jong1 = jong2;
          }

          final choIndex = choHash[cho];
          final jungIndex = jungHash[jung1];
          final jongIndex = jong1 != null ? jongHash[jong1] ?? 0 : 0;

          if (choIndex == null || jungIndex == null) {
            return; // or fallback
          }

          hangul = String.fromCharCode(
            (choIndex * 21 + jungIndex) * 28 + jongIndex + 0xAC00,
          );

          // hangul = String.fromCharCode(
          //   (choHash[cho]! * 21 + jungHash[jung1]!) * 28 +
          //       jongHash[jong1]! +
          //       0xAC00,
          // );
        }

        if (completeIndex + step >= index) {
          result.add(hangul);
          completeIndex = index;
          return;
        }

        step++;
      }
    }

    for (int i = 0; i < array.length; i++) {
      final code = array[i].codeUnitAt(0);

      if (!_isCho(code) && !_isJung(code) && !_isJong(code)) {
        makeHangul(i - 1);
        makeHangul(i);
        stage = 0;
        continue;
      }

      if (stage == 0) {
        if (_isCho(code)) {
          stage = 1;
        } else if (_isJung(code)) {
          stage = 4;
        }
      } else if (stage == 1) {
        if (_isJung(code)) {
          stage = 2;
        } else {
          final join = previousCode != null
              ? _isJongJoinable(previousCode, code)
              : null;

          if (join != null) {
            stage = 5;
          } else {
            makeHangul(i - 1);
          }
        }
      } else if (stage == 2) {
        if (_isJong(code)) {
          stage = 3;
        } else if (_isJung(code)) {
          final join = previousCode != null
              ? _isJungJoinable(previousCode, code)
              : null;

          if (join == null) {
            makeHangul(i - 1);
            stage = 4;
          }
        } else {
          makeHangul(i - 1);
          stage = 1;
        }
      } else if (stage == 3) {
        if (_isJong(code)) {
          final join = previousCode != null
              ? _isJongJoinable(previousCode, code)
              : null;

          if (!jongJoined && join != null) {
            jongJoined = true;
          } else {
            makeHangul(i - 1);
            stage = 1;
          }
        } else if (_isCho(code)) {
          makeHangul(i - 1);
          stage = 1;
        } else if (_isJung(code)) {
          makeHangul(i - 2);
          stage = 2;
        }
      } else if (stage == 4) {
        if (_isJung(code)) {
          final join = previousCode != null
              ? _isJungJoinable(previousCode, code)
              : null;

          if (join != null) {
            makeHangul(i);
            stage = 0;
          } else {
            makeHangul(i - 1);
          }
        } else {
          makeHangul(i - 1);
          stage = 1;
        }
      } else if (stage == 5) {
        if (_isJung(code)) {
          makeHangul(i - 2);
          stage = 2;
        } else {
          makeHangul(i - 1);
          stage = 1;
        }
      }

      previousCode = code;
    }

    makeHangul(array.length - 1);

    return result.join();
  }
}
