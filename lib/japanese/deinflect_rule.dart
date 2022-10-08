class DeinflectRule {
  String kanaIn;
  String kanaOut;
  List<String> rulesIn;
  List<String> rulesOut;

  DeinflectRule(
      {required this.kanaIn,
      required this.kanaOut,
      required this.rulesIn,
      required this.rulesOut});
}

// https://github.com/FooSoft/yomichan/blob/master/ext/data/deinflect.json
Map<String, List<DeinflectRule>> deinflectRules = {
  '-ba': [
    DeinflectRule(
        kanaIn: 'ければ', kanaOut: 'い', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(kanaIn: 'えば', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'けば', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'げば', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'せば', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'てば', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ねば', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'べば', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'めば', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'れば',
        kanaOut: 'る',
        rulesIn: [],
        rulesOut: ['v1', 'v5', 'vk', 'vs', 'vz']),
  ],
  '-chau': [
    DeinflectRule(
        kanaIn: 'ちゃう', kanaOut: 'る', rulesIn: ['v5'], rulesOut: ['v1']),
    DeinflectRule(
        kanaIn: 'いじゃう', kanaOut: 'ぐ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'いちゃう', kanaOut: 'く', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'しちゃう', kanaOut: 'す', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちゃう', kanaOut: 'う', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちゃう', kanaOut: 'く', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちゃう', kanaOut: 'つ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちゃう', kanaOut: 'る', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んじゃう', kanaOut: 'ぬ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んじゃう', kanaOut: 'ぶ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んじゃう', kanaOut: 'む', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じちゃう', kanaOut: 'ずる', rulesIn: ['v5'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'しちゃう', kanaOut: 'する', rulesIn: ['v5'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為ちゃう', kanaOut: '為る', rulesIn: ['v5'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'きちゃう', kanaOut: 'くる', rulesIn: ['v5'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来ちゃう', kanaOut: '来る', rulesIn: ['v5'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來ちゃう', kanaOut: '來る', rulesIn: ['v5'], rulesOut: ['vk']),
  ],
  '-chimau': [
    DeinflectRule(
        kanaIn: 'ちまう', kanaOut: 'る', rulesIn: ['v5'], rulesOut: ['v1']),
    DeinflectRule(
        kanaIn: 'いじまう', kanaOut: 'ぐ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'いちまう', kanaOut: 'く', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'しちまう', kanaOut: 'す', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちまう', kanaOut: 'う', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちまう', kanaOut: 'く', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちまう', kanaOut: 'つ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちまう', kanaOut: 'る', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んじまう', kanaOut: 'ぬ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んじまう', kanaOut: 'ぶ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んじまう', kanaOut: 'む', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じちまう', kanaOut: 'ずる', rulesIn: ['v5'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'しちまう', kanaOut: 'する', rulesIn: ['v5'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為ちまう', kanaOut: '為る', rulesIn: ['v5'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'きちまう', kanaOut: 'くる', rulesIn: ['v5'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来ちまう', kanaOut: '来る', rulesIn: ['v5'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來ちまう', kanaOut: '來る', rulesIn: ['v5'], rulesOut: ['vk']),
  ],
  '-shimau': [
    DeinflectRule(
        kanaIn: 'てしまう', kanaOut: 'て', rulesIn: ['v5'], rulesOut: ['iru']),
    DeinflectRule(
        kanaIn: 'でしまう', kanaOut: 'で', rulesIn: ['v5'], rulesOut: ['iru']),
  ],
  '-nasai': [
    DeinflectRule(kanaIn: 'なさい', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'いなさい', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'きなさい', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ぎなさい', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'しなさい', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ちなさい', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'になさい', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'びなさい', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'みなさい', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'りなさい', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'じなさい', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'しなさい', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為なさい', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'きなさい', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来なさい', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來なさい', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  '-sou': [
    DeinflectRule(kanaIn: 'そう', kanaOut: 'い', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(kanaIn: 'そう', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'いそう', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'きそう', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ぎそう', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'しそう', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ちそう', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'にそう', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'びそう', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'みそう', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'りそう', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'じそう', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'しそう', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為そう', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'きそう', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来そう', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來そう', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  '-sugiru': [
    DeinflectRule(
        kanaIn: 'すぎる', kanaOut: 'い', rulesIn: ['v1'], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'すぎる', kanaOut: 'る', rulesIn: ['v1'], rulesOut: ['v1']),
    DeinflectRule(
        kanaIn: 'いすぎる', kanaOut: 'う', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'きすぎる', kanaOut: 'く', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ぎすぎる', kanaOut: 'ぐ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'しすぎる', kanaOut: 'す', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ちすぎる', kanaOut: 'つ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'にすぎる', kanaOut: 'ぬ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'びすぎる', kanaOut: 'ぶ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'みすぎる', kanaOut: 'む', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'りすぎる', kanaOut: 'る', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じすぎる', kanaOut: 'ずる', rulesIn: ['v1'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'しすぎる', kanaOut: 'する', rulesIn: ['v1'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為すぎる', kanaOut: '為る', rulesIn: ['v1'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'きすぎる', kanaOut: 'くる', rulesIn: ['v1'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来すぎる', kanaOut: '来る', rulesIn: ['v1'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來すぎる', kanaOut: '來る', rulesIn: ['v1'], rulesOut: ['vk']),
  ],
  '-tai': [
    DeinflectRule(
        kanaIn: 'たい', kanaOut: 'る', rulesIn: ['adj-i'], rulesOut: ['v1']),
    DeinflectRule(
        kanaIn: 'いたい', kanaOut: 'う', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'きたい', kanaOut: 'く', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ぎたい', kanaOut: 'ぐ', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'したい', kanaOut: 'す', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ちたい', kanaOut: 'つ', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'にたい', kanaOut: 'ぬ', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'びたい', kanaOut: 'ぶ', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'みたい', kanaOut: 'む', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'りたい', kanaOut: 'る', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じたい', kanaOut: 'ずる', rulesIn: ['adj-i'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'したい', kanaOut: 'する', rulesIn: ['adj-i'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為たい', kanaOut: '為る', rulesIn: ['adj-i'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'きたい', kanaOut: 'くる', rulesIn: ['adj-i'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来たい', kanaOut: '来る', rulesIn: ['adj-i'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來たい', kanaOut: '來る', rulesIn: ['adj-i'], rulesOut: ['vk']),
  ],
  '-tara': [
    DeinflectRule(
        kanaIn: 'かったら', kanaOut: 'い', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(kanaIn: 'たら', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'いたら', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'いだら', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'したら', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ったら', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ったら', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ったら', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'んだら', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'んだら', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'んだら', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'じたら', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'したら', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為たら', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'きたら', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来たら', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來たら', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: 'いったら', kanaOut: 'いく', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'おうたら', kanaOut: 'おう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'こうたら', kanaOut: 'こう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'そうたら', kanaOut: 'そう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'とうたら', kanaOut: 'とう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '行ったら', kanaOut: '行く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '逝ったら', kanaOut: '逝く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '往ったら', kanaOut: '往く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '請うたら', kanaOut: '請う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '乞うたら', kanaOut: '乞う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '恋うたら', kanaOut: '恋う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '問うたら', kanaOut: '問う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '負うたら', kanaOut: '負う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '沿うたら', kanaOut: '沿う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '添うたら', kanaOut: '添う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '副うたら', kanaOut: '副う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '厭うたら', kanaOut: '厭う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'のたもうたら', kanaOut: 'のたまう', rulesIn: [], rulesOut: ['v5']),
  ],
  '-tari': [
    DeinflectRule(
        kanaIn: 'かったり', kanaOut: 'い', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(kanaIn: 'たり', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'いたり', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'いだり', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'したり', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ったり', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ったり', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ったり', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'んだり', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'んだり', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'んだり', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'じたり', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'したり', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為たり', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'きたり', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来たり', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來たり', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: 'いったり', kanaOut: 'いく', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'おうたり', kanaOut: 'おう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'こうたり', kanaOut: 'こう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'そうたり', kanaOut: 'そう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'とうたり', kanaOut: 'とう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '行ったり', kanaOut: '行く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '逝ったり', kanaOut: '逝く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '往ったり', kanaOut: '往く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '請うたり', kanaOut: '請う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '乞うたり', kanaOut: '乞う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '恋うたり', kanaOut: '恋う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '問うたり', kanaOut: '問う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '負うたり', kanaOut: '負う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '沿うたり', kanaOut: '沿う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '添うたり', kanaOut: '添う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '副うたり', kanaOut: '副う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '厭うたり', kanaOut: '厭う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'のたもうたり', kanaOut: 'のたまう', rulesIn: [], rulesOut: ['v5']),
  ],
  '-te': [
    DeinflectRule(
        kanaIn: 'くて', kanaOut: 'い', rulesIn: ['iru'], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'て', kanaOut: 'る', rulesIn: ['iru'], rulesOut: ['v1']),
    DeinflectRule(
        kanaIn: 'いて', kanaOut: 'く', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'いで', kanaOut: 'ぐ', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'して', kanaOut: 'す', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'って', kanaOut: 'う', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'って', kanaOut: 'つ', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'って', kanaOut: 'る', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んで', kanaOut: 'ぬ', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んで', kanaOut: 'ぶ', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んで', kanaOut: 'む', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じて', kanaOut: 'ずる', rulesIn: ['iru'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'して', kanaOut: 'する', rulesIn: ['iru'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為て', kanaOut: '為る', rulesIn: ['iru'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'きて', kanaOut: 'くる', rulesIn: ['iru'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来て', kanaOut: '来る', rulesIn: ['iru'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來て', kanaOut: '來る', rulesIn: ['iru'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: 'いって', kanaOut: 'いく', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'おうて', kanaOut: 'おう', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'こうて', kanaOut: 'こう', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'そうて', kanaOut: 'そう', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'とうて', kanaOut: 'とう', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '行って', kanaOut: '行く', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '逝って', kanaOut: '逝く', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '往って', kanaOut: '往く', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '請うて', kanaOut: '請う', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '乞うて', kanaOut: '乞う', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '恋うて', kanaOut: '恋う', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '問うて', kanaOut: '問う', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '負うて', kanaOut: '負う', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '沿うて', kanaOut: '沿う', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '添うて', kanaOut: '添う', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '副うて', kanaOut: '副う', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: '厭うて', kanaOut: '厭う', rulesIn: ['iru'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'のたもうて', kanaOut: 'のたまう', rulesIn: ['iru'], rulesOut: ['v5']),
  ],
  '-zu': [
    DeinflectRule(kanaIn: 'ず', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'かず', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'がず', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'さず', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'たず', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'なず', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ばず', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'まず', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'らず', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'わず', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ぜず', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'せず', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為ず', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'こず', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来ず', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來ず', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  '-nu': [
    DeinflectRule(kanaIn: 'ぬ', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'かぬ', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'がぬ', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'さぬ', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'たぬ', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'なぬ', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ばぬ', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'まぬ', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'らぬ', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'わぬ', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ぜぬ', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'せぬ', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為ぬ', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'こぬ', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来ぬ', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來ぬ', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  'adv': [
    DeinflectRule(kanaIn: 'く', kanaOut: 'い', rulesIn: [], rulesOut: ['adj-i']),
  ],
  'causative': [
    DeinflectRule(
        kanaIn: 'させる', kanaOut: 'る', rulesIn: ['v1'], rulesOut: ['v1']),
    DeinflectRule(
        kanaIn: 'かせる', kanaOut: 'く', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'がせる', kanaOut: 'ぐ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'させる', kanaOut: 'す', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'たせる', kanaOut: 'つ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'なせる', kanaOut: 'ぬ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ばせる', kanaOut: 'ぶ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ませる', kanaOut: 'む', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'らせる', kanaOut: 'る', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'わせる', kanaOut: 'う', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じさせる', kanaOut: 'ずる', rulesIn: ['v1'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'ぜさせる', kanaOut: 'ずる', rulesIn: ['v1'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'させる', kanaOut: 'する', rulesIn: ['v1'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為せる', kanaOut: '為る', rulesIn: ['v1'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'せさせる', kanaOut: 'する', rulesIn: ['v1'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為させる', kanaOut: '為る', rulesIn: ['v1'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'こさせる', kanaOut: 'くる', rulesIn: ['v1'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来させる', kanaOut: '来る', rulesIn: ['v1'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來させる', kanaOut: '來る', rulesIn: ['v1'], rulesOut: ['vk']),
  ],
  'imperative': [
    DeinflectRule(kanaIn: 'ろ', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'よ', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'え', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'け', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'げ', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'せ', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'て', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ね', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'べ', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'め', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'れ', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'じろ', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'ぜよ', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'しろ', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'せよ', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為ろ', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為よ', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'こい', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来い', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來い', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  'imperative negative': [
    DeinflectRule(
        kanaIn: 'な',
        kanaOut: '',
        rulesIn: [],
        rulesOut: ['v1', 'v5', 'vk', 'vs', 'vz']),
  ],
  'masu stem': [
    DeinflectRule(kanaIn: 'い', kanaOut: 'いる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'え', kanaOut: 'える', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'き', kanaOut: 'きる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'ぎ', kanaOut: 'ぎる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'け', kanaOut: 'ける', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'げ', kanaOut: 'げる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'じ', kanaOut: 'じる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'せ', kanaOut: 'せる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'ぜ', kanaOut: 'ぜる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'ち', kanaOut: 'ちる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'て', kanaOut: 'てる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'で', kanaOut: 'でる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'に', kanaOut: 'にる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'ね', kanaOut: 'ねる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'ひ', kanaOut: 'ひる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'び', kanaOut: 'びる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'へ', kanaOut: 'へる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'べ', kanaOut: 'べる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'み', kanaOut: 'みる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'め', kanaOut: 'める', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'り', kanaOut: 'りる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'れ', kanaOut: 'れる', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'い', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'き', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ぎ', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'し', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ち', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'に', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'び', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'み', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'り', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'き', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  'negative': [
    DeinflectRule(
        kanaIn: 'くない', kanaOut: 'い', rulesIn: ['adj-i'], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'ない', kanaOut: 'る', rulesIn: ['adj-i'], rulesOut: ['v1']),
    DeinflectRule(
        kanaIn: 'かない', kanaOut: 'く', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'がない', kanaOut: 'ぐ', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'さない', kanaOut: 'す', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'たない', kanaOut: 'つ', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'なない', kanaOut: 'ぬ', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ばない', kanaOut: 'ぶ', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'まない', kanaOut: 'む', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'らない', kanaOut: 'る', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'わない', kanaOut: 'う', rulesIn: ['adj-i'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じない', kanaOut: 'ずる', rulesIn: ['adj-i'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'しない', kanaOut: 'する', rulesIn: ['adj-i'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為ない', kanaOut: '為る', rulesIn: ['adj-i'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'こない', kanaOut: 'くる', rulesIn: ['adj-i'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来ない', kanaOut: '来る', rulesIn: ['adj-i'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來ない', kanaOut: '來る', rulesIn: ['adj-i'], rulesOut: ['vk']),
  ],
  'noun': [
    DeinflectRule(kanaIn: 'さ', kanaOut: 'い', rulesIn: [], rulesOut: ['adj-i']),
  ],
  'passive': [
    DeinflectRule(
        kanaIn: 'かれる', kanaOut: 'く', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'がれる', kanaOut: 'ぐ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'される', kanaOut: 'す', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'たれる', kanaOut: 'つ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'なれる', kanaOut: 'ぬ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ばれる', kanaOut: 'ぶ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'まれる', kanaOut: 'む', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'われる', kanaOut: 'う', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'られる', kanaOut: 'る', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じされる', kanaOut: 'ずる', rulesIn: ['v1'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'ぜされる', kanaOut: 'ずる', rulesIn: ['v1'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'される', kanaOut: 'する', rulesIn: ['v1'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為れる', kanaOut: '為る', rulesIn: ['v1'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'こられる', kanaOut: 'くる', rulesIn: ['v1'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来られる', kanaOut: '来る', rulesIn: ['v1'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來られる', kanaOut: '來る', rulesIn: ['v1'], rulesOut: ['vk']),
  ],
  'past': [
    DeinflectRule(
        kanaIn: 'かった', kanaOut: 'い', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(kanaIn: 'た', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'いた', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'いだ', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'した', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'った', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'った', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'った', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'んだ', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'んだ', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'んだ', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'じた', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'した', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為た', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'きた', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来た', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來た', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: 'いった', kanaOut: 'いく', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'おうた', kanaOut: 'おう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'こうた', kanaOut: 'こう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'そうた', kanaOut: 'そう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'とうた', kanaOut: 'とう', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '行った', kanaOut: '行く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '逝った', kanaOut: '逝く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '往った', kanaOut: '往く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '請うた', kanaOut: '請う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '乞うた', kanaOut: '乞う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '恋うた', kanaOut: '恋う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '問うた', kanaOut: '問う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '負うた', kanaOut: '負う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '沿うた', kanaOut: '沿う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '添うた', kanaOut: '添う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '副うた', kanaOut: '副う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: '厭うた', kanaOut: '厭う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'のたもうた', kanaOut: 'のたまう', rulesIn: [], rulesOut: ['v5']),
  ],
  'polite': [
    DeinflectRule(kanaIn: 'ます', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'います', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'きます', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ぎます', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'します', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ちます', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'にます', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'びます', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'みます', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ります', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'じます', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'します', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為ます', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'きます', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来ます', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來ます', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  'polite negative': [
    DeinflectRule(
        kanaIn: 'くありません', kanaOut: 'い', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(kanaIn: 'ません', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'いません', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'きません', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ぎません', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'しません', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ちません', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'にません', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'びません', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'みません', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'りません', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'じません', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'しません', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為ません', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'きません', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来ません', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來ません', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  'polite past': [
    DeinflectRule(kanaIn: 'ました', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'いました', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'きました', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ぎました', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'しました', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ちました', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'にました', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'びました', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'みました', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'りました', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'じました', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'しました', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為ました', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'きました', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来ました', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來ました', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  'polite past negative': [
    DeinflectRule(
        kanaIn: 'くありませんでした', kanaOut: 'い', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'ませんでした', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(
        kanaIn: 'いませんでした', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'きませんでした', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ぎませんでした', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'しませんでした', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ちませんでした', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'にませんでした', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'びませんでした', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'みませんでした', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'りませんでした', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じませんでした', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'しませんでした', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為ませんでした', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'きませんでした', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来ませんでした', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來ませんでした', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  'polite volitional': [
    DeinflectRule(kanaIn: 'ましょう', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'いましょう', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'きましょう', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ぎましょう', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'しましょう', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ちましょう', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'にましょう', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'びましょう', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'みましょう', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'りましょう', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じましょう', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'しましょう', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為ましょう', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'きましょう', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来ましょう', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來ましょう', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  'potential': [
    DeinflectRule(
        kanaIn: 'れる', kanaOut: 'る', rulesIn: ['v1'], rulesOut: ['v1', 'v5']),
    DeinflectRule(
        kanaIn: 'える', kanaOut: 'う', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ける', kanaOut: 'く', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'げる', kanaOut: 'ぐ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'せる', kanaOut: 'す', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'てる', kanaOut: 'つ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ねる', kanaOut: 'ぬ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'べる', kanaOut: 'ぶ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'める', kanaOut: 'む', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'これる', kanaOut: 'くる', rulesIn: ['v1'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来れる', kanaOut: '来る', rulesIn: ['v1'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來れる', kanaOut: '來る', rulesIn: ['v1'], rulesOut: ['vk']),
  ],
  'potential or passive': [
    DeinflectRule(
        kanaIn: 'られる', kanaOut: 'る', rulesIn: ['v1'], rulesOut: ['v1']),
    DeinflectRule(
        kanaIn: 'ざれる', kanaOut: 'ずる', rulesIn: ['v1'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'ぜられる', kanaOut: 'ずる', rulesIn: ['v1'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'せられる', kanaOut: 'する', rulesIn: ['v1'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為られる', kanaOut: '為る', rulesIn: ['v1'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'こられる', kanaOut: 'くる', rulesIn: ['v1'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来られる', kanaOut: '来る', rulesIn: ['v1'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來られる', kanaOut: '來る', rulesIn: ['v1'], rulesOut: ['vk']),
  ],
  'volitional': [
    DeinflectRule(kanaIn: 'よう', kanaOut: 'る', rulesIn: [], rulesOut: ['v1']),
    DeinflectRule(kanaIn: 'おう', kanaOut: 'う', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'こう', kanaOut: 'く', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ごう', kanaOut: 'ぐ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'そう', kanaOut: 'す', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'とう', kanaOut: 'つ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'のう', kanaOut: 'ぬ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ぼう', kanaOut: 'ぶ', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'もう', kanaOut: 'む', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'ろう', kanaOut: 'る', rulesIn: [], rulesOut: ['v5']),
    DeinflectRule(kanaIn: 'じよう', kanaOut: 'ずる', rulesIn: [], rulesOut: ['vz']),
    DeinflectRule(kanaIn: 'しよう', kanaOut: 'する', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: '為よう', kanaOut: '為る', rulesIn: [], rulesOut: ['vs']),
    DeinflectRule(kanaIn: 'こよう', kanaOut: 'くる', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '来よう', kanaOut: '来る', rulesIn: [], rulesOut: ['vk']),
    DeinflectRule(kanaIn: '來よう', kanaOut: '來る', rulesIn: [], rulesOut: ['vk']),
  ],
  'causative passive': [
    DeinflectRule(
        kanaIn: 'かされる', kanaOut: 'く', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'がされる', kanaOut: 'ぐ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'たされる', kanaOut: 'つ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'なされる', kanaOut: 'ぬ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ばされる', kanaOut: 'ぶ', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'まされる', kanaOut: 'む', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'らされる', kanaOut: 'る', rulesIn: ['v1'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'わされる', kanaOut: 'う', rulesIn: ['v1'], rulesOut: ['v5']),
  ],
  '-toku': [
    DeinflectRule(
        kanaIn: 'とく', kanaOut: 'る', rulesIn: ['v5'], rulesOut: ['v1']),
    DeinflectRule(
        kanaIn: 'いとく', kanaOut: 'く', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'いどく', kanaOut: 'ぐ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'しとく', kanaOut: 'す', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っとく', kanaOut: 'う', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っとく', kanaOut: 'つ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っとく', kanaOut: 'る', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んどく', kanaOut: 'ぬ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んどく', kanaOut: 'ぶ', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んどく', kanaOut: 'む', rulesIn: ['v5'], rulesOut: ['v5']),
    DeinflectRule(
        kanaIn: 'じとく', kanaOut: 'ずる', rulesIn: ['v5'], rulesOut: ['vz']),
    DeinflectRule(
        kanaIn: 'しとく', kanaOut: 'する', rulesIn: ['v5'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: '為とく', kanaOut: '為る', rulesIn: ['v5'], rulesOut: ['vs']),
    DeinflectRule(
        kanaIn: 'きとく', kanaOut: 'くる', rulesIn: ['v5'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '来とく', kanaOut: '来る', rulesIn: ['v5'], rulesOut: ['vk']),
    DeinflectRule(
        kanaIn: '來とく', kanaOut: '來る', rulesIn: ['v5'], rulesOut: ['vk']),
  ],
  'progressive or perfect': [
    DeinflectRule(
        kanaIn: 'ている', kanaOut: 'て', rulesIn: ['v1'], rulesOut: ['iru']),
    DeinflectRule(
        kanaIn: 'ておる', kanaOut: 'て', rulesIn: ['v5'], rulesOut: ['iru']),
    DeinflectRule(
        kanaIn: 'てる', kanaOut: 'て', rulesIn: ['v1'], rulesOut: ['iru']),
    DeinflectRule(
        kanaIn: 'でいる', kanaOut: 'で', rulesIn: ['v1'], rulesOut: ['iru']),
    DeinflectRule(
        kanaIn: 'でおる', kanaOut: 'で', rulesIn: ['v5'], rulesOut: ['iru']),
    DeinflectRule(
        kanaIn: 'でる', kanaOut: 'で', rulesIn: ['v1'], rulesOut: ['iru']),
    DeinflectRule(
        kanaIn: 'とる', kanaOut: 'て', rulesIn: ['v5'], rulesOut: ['iru']),
    DeinflectRule(
        kanaIn: 'ないでいる', kanaOut: 'ない', rulesIn: ['v1'], rulesOut: ['adj-i']),
  ],
  '-ki': [
    DeinflectRule(kanaIn: 'き', kanaOut: 'い', rulesIn: [], rulesOut: ['adj-i']),
  ],
  '-ge': [
    DeinflectRule(
        kanaIn: 'しげ', kanaOut: 'しい', rulesIn: [], rulesOut: ['adj-i']),
  ],
  '-e': [
    DeinflectRule(
        kanaIn: 'ねえ', kanaOut: 'ない', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'めえ', kanaOut: 'むい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'みい', kanaOut: 'むい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'ちぇえ', kanaOut: 'つい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'ちい', kanaOut: 'つい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'せえ', kanaOut: 'すい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'ええ', kanaOut: 'いい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'ええ', kanaOut: 'わい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'ええ', kanaOut: 'よい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'いぇえ', kanaOut: 'よい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'うぇえ', kanaOut: 'わい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'けえ', kanaOut: 'かい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'げえ', kanaOut: 'がい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'げえ', kanaOut: 'ごい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'せえ', kanaOut: 'さい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'めえ', kanaOut: 'まい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'ぜえ', kanaOut: 'ずい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'っぜえ', kanaOut: 'ずい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'れえ', kanaOut: 'らい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'れえ', kanaOut: 'らい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'ちぇえ', kanaOut: 'ちゃい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'でえ', kanaOut: 'どい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'れえ', kanaOut: 'れい', rulesIn: [], rulesOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'べえ', kanaOut: 'ばい', rulesIn: [], rulesOut: ['adj-i']),
  ],
};
