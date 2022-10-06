class DeinflectRule {
  String kanaIn;
  String kanaOut;
  List<String> tagsIn;
  List<String> tagsOut;

  DeinflectRule(
      {required this.kanaIn,
      required this.kanaOut,
      required this.tagsIn,
      required this.tagsOut});
}

Map<String, List<DeinflectRule>> deinflectRules = {
  '-ba': [
    DeinflectRule(kanaIn: 'えば', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'けば', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'げば', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'せば', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'てば', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ねば', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'べば', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'めば', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'れば',
        kanaOut: 'る',
        tagsIn: [],
        tagsOut: ['v1', 'v5', 'vk', 'vs']),
    DeinflectRule(kanaIn: 'ければ', kanaOut: 'い', tagsIn: [], tagsOut: ['adj-i']),
  ],
  '-chau': [
    DeinflectRule(
        kanaIn: 'ちゃう', kanaOut: 'る', tagsIn: ['v5'], tagsOut: ['v1', 'vk']),
    DeinflectRule(
        kanaIn: 'いじゃう', kanaOut: 'ぐ', tagsIn: ['v5'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'いちゃう', kanaOut: 'く', tagsIn: ['v5'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'きちゃう', kanaOut: 'くる', tagsIn: ['v5'], tagsOut: ['vk']),
    DeinflectRule(
        kanaIn: 'しちゃう', kanaOut: 'す', tagsIn: ['v5'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'しちゃう', kanaOut: 'する', tagsIn: ['v5'], tagsOut: ['vs']),
    DeinflectRule(
        kanaIn: 'っちゃう', kanaOut: 'う', tagsIn: ['v5'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちゃう', kanaOut: 'く', tagsIn: ['v5'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちゃう', kanaOut: 'つ', tagsIn: ['v5'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'っちゃう', kanaOut: 'る', tagsIn: ['v5'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んじゃう', kanaOut: 'ぬ', tagsIn: ['v5'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んじゃう', kanaOut: 'ぶ', tagsIn: ['v5'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'んじゃう', kanaOut: 'む', tagsIn: ['v5'], tagsOut: ['v5']),
  ],
  '-nasai': [
    DeinflectRule(
        kanaIn: 'なさい', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'いなさい', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きなさい', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きなさい', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'ぎなさい', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しなさい', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しなさい', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'ちなさい', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'になさい', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'びなさい', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'みなさい', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'りなさい', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
  ],
  '-sou': [
    DeinflectRule(kanaIn: 'そう', kanaOut: 'い', tagsIn: [], tagsOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'そう', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'いそう', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きそう', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きそう', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'ぎそう', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しそう', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しそう', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'ちそう', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'にそう', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'びそう', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'みそう', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'りそう', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
  ],
  '-sugiru': [
    DeinflectRule(
        kanaIn: 'すぎる', kanaOut: 'い', tagsIn: ['v1'], tagsOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'すぎる', kanaOut: 'る', tagsIn: ['v1'], tagsOut: ['v1', 'vk']),
    DeinflectRule(
        kanaIn: 'いすぎる', kanaOut: 'う', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'きすぎる', kanaOut: 'く', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'きすぎる', kanaOut: 'くる', tagsIn: ['v1'], tagsOut: ['vk']),
    DeinflectRule(
        kanaIn: 'ぎすぎる', kanaOut: 'ぐ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'しすぎる', kanaOut: 'す', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'しすぎる', kanaOut: 'する', tagsIn: ['v1'], tagsOut: ['vs']),
    DeinflectRule(
        kanaIn: 'ちすぎる', kanaOut: 'つ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'にすぎる', kanaOut: 'ぬ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'びすぎる', kanaOut: 'ぶ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'みすぎる', kanaOut: 'む', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'りすぎる', kanaOut: 'る', tagsIn: ['v1'], tagsOut: ['v5']),
  ],
  '-tai': [
    DeinflectRule(
        kanaIn: 'たい', kanaOut: 'る', tagsIn: ['adj-i'], tagsOut: ['v1', 'vk']),
    DeinflectRule(
        kanaIn: 'いたい', kanaOut: 'う', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'きたい', kanaOut: 'く', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'きたい', kanaOut: 'くる', tagsIn: ['adj-i'], tagsOut: ['vk']),
    DeinflectRule(
        kanaIn: 'ぎたい', kanaOut: 'ぐ', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'したい', kanaOut: 'す', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'したい', kanaOut: 'する', tagsIn: ['adj-i'], tagsOut: ['vs']),
    DeinflectRule(
        kanaIn: 'ちたい', kanaOut: 'つ', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'にたい', kanaOut: 'ぬ', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'びたい', kanaOut: 'ぶ', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'みたい', kanaOut: 'む', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'りたい', kanaOut: 'る', tagsIn: ['adj-i'], tagsOut: ['v5']),
  ],
  '-tara': [
    DeinflectRule(
        kanaIn: 'たら', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'いたら', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'いだら', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きたら', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'したら', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'したら', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'ったら', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ったら', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ったら', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んだら', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んだら', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んだら', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'かったら', kanaOut: 'い', tagsIn: [], tagsOut: ['adj-i']),
  ],
  '-tari': [
    DeinflectRule(
        kanaIn: 'たり', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'いたり', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'いだり', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きたり', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'したり', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'したり', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'ったり', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ったり', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ったり', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んだり', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んだり', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んだり', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'かったり', kanaOut: 'い', tagsIn: [], tagsOut: ['adj-i']),
  ],
  '-te': [
    DeinflectRule(kanaIn: 'て', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'いて', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'いで', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きて', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'くて', kanaOut: 'い', tagsIn: [], tagsOut: ['adj-i']),
    DeinflectRule(kanaIn: 'して', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'して', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'って', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'って', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'って', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'って', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んで', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んで', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んで', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
  ],
  '-zu': [
    DeinflectRule(kanaIn: 'ず', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'かず', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'がず', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'こず', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'さず', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'せず', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'たず', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'なず', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ばず', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'まず', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'らず', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'わず', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
  ],
  '-nu': [
    DeinflectRule(kanaIn: 'ぬ', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'かぬ', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'がぬ', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'こぬ', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'さぬ', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'せぬ', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'たぬ', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'なぬ', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ばぬ', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'まぬ', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'らぬ', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'わぬ', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
  ],
  'adv': [
    DeinflectRule(kanaIn: 'く', kanaOut: 'い', tagsIn: [], tagsOut: ['adj-i']),
  ],
  'causative': [
    DeinflectRule(kanaIn: 'かせる', kanaOut: 'く', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'がせる', kanaOut: 'ぐ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'させる', kanaOut: 'する', tagsIn: ['v1'], tagsOut: ['vs']),
    DeinflectRule(
        kanaIn: 'させる', kanaOut: 'る', tagsIn: ['v1'], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'たせる', kanaOut: 'つ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'なせる', kanaOut: 'ぬ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ばせる', kanaOut: 'ぶ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ませる', kanaOut: 'む', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'らせる', kanaOut: 'る', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'わせる', kanaOut: 'う', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'こさせる', kanaOut: 'くる', tagsIn: ['v1'], tagsOut: ['vk']),
  ],
  'imperative': [
    DeinflectRule(kanaIn: 'い', kanaOut: 'る', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'え', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'け', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'げ', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'せ', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'て', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ね', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'べ', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'め', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'よ', kanaOut: 'る', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'れ', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ろ', kanaOut: 'る', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'こい', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'しろ', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'せよ', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
  ],
  'imperative negative': [
    DeinflectRule(
        kanaIn: 'な',
        kanaOut: '',
        tagsIn: [],
        tagsOut: ['v1', 'v5', 'vk', 'vs']),
  ],
  'masu stem': [
    DeinflectRule(kanaIn: 'い', kanaOut: 'いる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'い', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'え', kanaOut: 'える', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'き', kanaOut: 'きる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'き', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ぎ', kanaOut: 'ぎる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'ぎ', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'け', kanaOut: 'ける', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'げ', kanaOut: 'げる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'し', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'じ', kanaOut: 'じる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'せ', kanaOut: 'せる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'ぜ', kanaOut: 'ぜる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'ち', kanaOut: 'ちる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'ち', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'て', kanaOut: 'てる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'で', kanaOut: 'でる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'に', kanaOut: 'にる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'に', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ね', kanaOut: 'ねる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'ひ', kanaOut: 'ひる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'び', kanaOut: 'びる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'び', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'へ', kanaOut: 'へる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'べ', kanaOut: 'べる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'み', kanaOut: 'みる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'み', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'め', kanaOut: 'める', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'り', kanaOut: 'りる', tagsIn: [], tagsOut: ['v1']),
    DeinflectRule(kanaIn: 'り', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'れ', kanaOut: 'れる', tagsIn: [], tagsOut: ['v1']),
  ],
  'negative': [
    DeinflectRule(
        kanaIn: 'ない', kanaOut: 'る', tagsIn: ['adj-i'], tagsOut: ['v1', 'vk']),
    DeinflectRule(
        kanaIn: 'かない', kanaOut: 'く', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'がない', kanaOut: 'ぐ', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'くない', kanaOut: 'い', tagsIn: ['adj-i'], tagsOut: ['adj-i']),
    DeinflectRule(
        kanaIn: 'こない', kanaOut: 'くる', tagsIn: ['adj-i'], tagsOut: ['vk']),
    DeinflectRule(
        kanaIn: 'さない', kanaOut: 'す', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'しない', kanaOut: 'する', tagsIn: ['adj-i'], tagsOut: ['vs']),
    DeinflectRule(
        kanaIn: 'たない', kanaOut: 'つ', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'なない', kanaOut: 'ぬ', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'ばない', kanaOut: 'ぶ', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'まない', kanaOut: 'む', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'らない', kanaOut: 'る', tagsIn: ['adj-i'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'わない', kanaOut: 'う', tagsIn: ['adj-i'], tagsOut: ['v5']),
  ],
  'noun': [
    DeinflectRule(kanaIn: 'さ', kanaOut: 'い', tagsIn: [], tagsOut: ['adj-i']),
  ],
  'passive': [
    DeinflectRule(kanaIn: 'かれる', kanaOut: 'く', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'がれる', kanaOut: 'ぐ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'される', kanaOut: 'する', tagsIn: ['v1'], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'たれる', kanaOut: 'つ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'なれる', kanaOut: 'ぬ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ばれる', kanaOut: 'ぶ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'まれる', kanaOut: 'む', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'われる', kanaOut: 'う', tagsIn: ['v1'], tagsOut: ['v5']),
  ],
  'passive or causative': [
    DeinflectRule(kanaIn: 'される', kanaOut: 'す', tagsIn: ['v1'], tagsOut: ['v5']),
  ],
  'past': [
    DeinflectRule(kanaIn: 'た', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'いた', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'いだ', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きた', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'した', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'した', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'った', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'った', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'った', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'った', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んだ', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んだ', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'んだ', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'かった', kanaOut: 'い', tagsIn: [], tagsOut: ['adj-i']),
  ],
  'polite': [
    DeinflectRule(
        kanaIn: 'ます', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'います', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きます', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きます', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'ぎます', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'します', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'します', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'ちます', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'にます', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'びます', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'みます', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ります', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
  ],
  'polite negative': [
    DeinflectRule(
        kanaIn: 'ません', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'いません', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きません', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きません', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'ぎません', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しません', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しません', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'ちません', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'にません', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'びません', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'みません', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'りません', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'くありません', kanaOut: 'い', tagsIn: [], tagsOut: ['adj-i']),
  ],
  'polite past': [
    DeinflectRule(
        kanaIn: 'ました', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'いました', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きました', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きました', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'ぎました', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しました', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しました', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'ちました', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'にました', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'びました', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'みました', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'りました', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
  ],
  'polite past negative': [
    DeinflectRule(
        kanaIn: 'ませんでした', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'いませんでした', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きませんでした', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'きませんでした', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'ぎませんでした', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しませんでした', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'しませんでした', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'ちませんでした', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'にませんでした', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'びませんでした', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'みませんでした', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'りませんでした', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'くありませんでした', kanaOut: 'い', tagsIn: [], tagsOut: ['adj-i']),
  ],
  'polite volitional': [
    DeinflectRule(
        kanaIn: 'ましょう', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'いましょう', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きましょう', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'きましょう', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'ぎましょう', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しましょう', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'しましょう', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
    DeinflectRule(kanaIn: 'ちましょう', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'にましょう', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'びましょう', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'みましょう', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'りましょう', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
  ],
  'potential': [
    DeinflectRule(kanaIn: 'える', kanaOut: 'う', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ける', kanaOut: 'く', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'げる', kanaOut: 'ぐ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'せる', kanaOut: 'す', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'てる', kanaOut: 'つ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ねる', kanaOut: 'ぬ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'べる', kanaOut: 'ぶ', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'める', kanaOut: 'む', tagsIn: ['v1'], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'れる',
        kanaOut: 'る',
        tagsIn: ['v1'],
        tagsOut: ['v1', 'v5', 'vk']),
    DeinflectRule(
        kanaIn: 'これる', kanaOut: 'くる', tagsIn: ['v1'], tagsOut: ['vk']),
  ],
  'potential or passive': [
    DeinflectRule(
        kanaIn: 'られる',
        kanaOut: 'る',
        tagsIn: ['v1'],
        tagsOut: ['v1', 'v5', 'vk']),
    DeinflectRule(
        kanaIn: 'こられる', kanaOut: 'くる', tagsIn: ['v1'], tagsOut: ['vk']),
  ],
  'volitional': [
    DeinflectRule(kanaIn: 'おう', kanaOut: 'う', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'こう', kanaOut: 'く', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ごう', kanaOut: 'ぐ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'そう', kanaOut: 'す', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'とう', kanaOut: 'つ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'のう', kanaOut: 'ぬ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'ぼう', kanaOut: 'ぶ', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'もう', kanaOut: 'む', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(
        kanaIn: 'よう', kanaOut: 'る', tagsIn: [], tagsOut: ['v1', 'vk']),
    DeinflectRule(kanaIn: 'ろう', kanaOut: 'る', tagsIn: [], tagsOut: ['v5']),
    DeinflectRule(kanaIn: 'こよう', kanaOut: 'くる', tagsIn: [], tagsOut: ['vk']),
    DeinflectRule(kanaIn: 'しよう', kanaOut: 'する', tagsIn: [], tagsOut: ['vs']),
  ],
};
