import 'package:flutter/widgets.dart';

class TextMatch extends StatelessWidget {
  const TextMatch(
    this.data,
    this.match, {
    this.ignoreCase = true,
    this.exactMatch = true,
    super.key,
    this.style,
    this.overflow,
    this.matchStyle,
    this.textSpansbuilder,
  });

  final String data;
  final String match;
  final bool ignoreCase;
  final bool exactMatch;
  final TextStyle? style;
  final TextStyle? matchStyle;
  final TextOverflow? overflow;
  final List<InlineSpan> Function(List<InlineSpan> matchText)? textSpansbuilder;

  List<InlineSpan> _matchTextToTextSpans(BuildContext context, String text, List<int> matchedIndexs) {
    final TextStyle matchStyle = this.matchStyle ?? const TextStyle(fontWeight: FontWeight.bold);

    final List<TextSpan> textSpans = [];

    for (int i = 0, len = matchedIndexs.length; i < len; i++) {
      final int matchedIndex = matchedIndexs[i];

      if (matchedIndex != 0) {
        int prevMatchedIndex = i == 0 ? 0 : matchedIndexs[i - 1] + 1;
        textSpans.add(TextSpan(text: text.substring(prevMatchedIndex, matchedIndex)));
      }

      textSpans.add(TextSpan(text: text[matchedIndex], style: matchStyle));

      if (i == len - 1) textSpans.add(TextSpan(text: text.substring(matchedIndex + 1)));
    }

    return textSpans;
  }

  @override
  Widget build(BuildContext context) {
    final String matchText = match;
    final String text = data;
    List<InlineSpan> textSpans = [];

    if (text.isNotEmpty) {
      final List<int> matchedIndexs = matchIndex(text, matchText, ignoreCase: ignoreCase, exactMatch: exactMatch);
      textSpans = matchedIndexs.isEmpty ? [TextSpan(text: text)] : _matchTextToTextSpans(context, text, matchedIndexs);
    }

    textSpans = textSpansbuilder != null ? textSpansbuilder!(textSpans) : textSpans;

    return Text.rich(
      TextSpan(children: textSpans),
      style: style,
      overflow: overflow,
    );
  }
}

List<int> matchIndex(String text, String match, {bool ignoreCase = true, bool exactMatch = true}) {
  final String finalText = ignoreCase ? text.toLowerCase() : text;
  final String finalMatch = ignoreCase ? match.toLowerCase() : match;
  List<int> matchIndexs = [];

  if (exactMatch) {
    final int index = finalText.indexOf(finalMatch);
    if (index != -1) {
      matchIndexs.addAll(List.generate(finalMatch.length, (i) => i + index));
    }
  } else {
    int matchPointerIndex = 0;
    int textStartIndex = 0;
    while (matchPointerIndex != finalMatch.length) {
      final int index = finalText.indexOf(finalMatch[matchPointerIndex], textStartIndex);
      if (index != -1) {
        matchIndexs.add(index);
        textStartIndex = index + 1;
      }

      matchPointerIndex++;
    }
  }

  if (matchIndexs.length != finalMatch.length) return [];

  return matchIndexs;
}
