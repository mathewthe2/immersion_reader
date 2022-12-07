List<String> hiraToMora(String hira) {
  /* Example:
          in:  'しゅんかしゅうとう'
         out: ['しゅ', 'ん', 'か', 'しゅ', 'う', 'と', 'う']
    */

  List<String> moraArr = [];
  const List<String> combiners = [
    'ゃ',
    'ゅ',
    'ょ',
    'ぁ',
    'ぃ',
    'ぅ',
    'ぇ',
    'ぉ',
    'ャ',
    'ュ',
    'ョ',
    'ァ',
    'ィ',
    'ゥ',
    'ェ',
    'ォ'
  ];

  int i = 0;
  while (i < hira.length) {
    if (i + 1 < hira.length && combiners.contains(hira[i + 1])) {
      moraArr.add('${hira[i]}${hira[i + 1]}');
      i += 2;
    } else {
      moraArr.add(hira[i]);
      i += 1;
    }
  }
  return moraArr;
}
