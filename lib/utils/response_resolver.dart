import 'dart:io';

import 'package:html/parser.dart';

import '../repositories/entities/entities.dart';

String replaceHex(String data) {
  return data.replaceAllMapped(
    // RegExp(r"\\x[0-9a-fA-F]{2}\\?"),
    RegExp(r"\\x[0-9a-fA-F]{2}"),
    (match) {
      String text = match.group(0)!.substring(2);
      // if (text.endsWith("\\")) text = text.substring(0, text.length - 1);

      return String.fromCharCode(int.parse(text, radix: 16));
      // \x22
    },
  );
}

String terseSpace(String data) {
  return data.replaceAll(RegExp(r"\s+"), " ");
}

List<String> extractHTML(String data) {
  final List<String> htmls = [];
  const startSymbol = "html:'";
  const endSymbol = "',opuin:";

  int startIndex = 0;
  int endIndex = 0;

  while (startIndex != -1 && endIndex != -1) {
    startIndex = data.indexOf(startSymbol, startIndex);
    if (startIndex == -1) break;

    endIndex = data.indexOf(endSymbol, startIndex);
    if (endIndex == -1) break;

    final html = data.substring(startIndex + startSymbol.length, endIndex).trim();
    htmls.add(html);
    startIndex = endIndex;
  }

  return htmls;
}

class ResponseMoment {
  const ResponseMoment({
    required this.moments,
    required this.friends,
  });

  final List<Moment> moments;
  final List<User> friends;
}

class ResponseResolver {
  // static ResponseMoment moments(String body, String qq) {
  //   String data = terseSpace(body);
  //   data = replaceHex(data);
  //   data = data.replaceAll(r"\", "");
  //   final htmls = extractHTML(data);

  //   final Map<String, Moment> moments = {};
  //   final Map<String, User> users = {};

  //   // File("test/moments_html.html").writeAsStringSync("");
  //   // int i = 0;
  //   for (final html in htmls) {
  //     // print(i);
  //     // i++;

  //     // File("test/moments_html.html").writeAsStringSync("$html\n\n", mode: FileMode.append);

  //     final doc = parse(html);

  //     final feedData = doc.querySelector("[name=feed_data]")!;
  //     final ownQQ = feedData.attributes["data-uin"]!;
  //     // 屏蔽不是自己的说说
  //     if (ownQQ != qq) continue;

  //     final momentId = feedData.attributes["data-tid"]!;
  //     moments.putIfAbsent(
  //       momentId,
  //       () => Moment(
  //         id: momentId,
  //         likes: [],
  //         content: "",
  //         comments: [],
  //       ),
  //     );

  //     // Friend
  //     final friendEl = doc.querySelector(".f-name.q_namecard")!;
  //     final friendUser = User(
  //       qq: friendEl.attributes["link"]!.split("_").last,
  //       nickname: friendEl.text,
  //     );
  //     users.putIfAbsent(friendUser.qq, () => friendUser);

  //     // 这个时间貌似是点赞或者评论时间等其他时间，不是说说发表时间
  //     // final timeEl = doc.querySelector(".info-detail .ui-mr8.state")!;

  //     // 礼物, 相册，送的礼物 没有此class
  //     // 内容如果是纯的视频，貌似就没有在这里面体现，只有一个 发表说说
  //     // 内容是说说发表内容
  //     final contentEl = doc.querySelector(".txt-box-title.ellipsis-one");
  //     if (contentEl != null) {
  //       contentEl.nodes[0].remove(); // nickname
  //       contentEl.nodes[1].remove(); // :
  //       String content = contentEl.innerHtml;

  //       if (content.startsWith("&nbsp;")) {
  //         content = content.replaceFirst("&nbsp;", "");
  //       }

  //       moments.update(momentId, (m) => m.copyWith(content: content));
  //     }

  //     final typeEl = doc.querySelector(".user-info .ui-mr10.state")!;
  //     final like = switch (typeEl.text) {
  //       "赞了我的说说" => 1,
  //       "评论" => 0,
  //       "回复" => 0,
  //       "送我礼物" => 0,
  //       String() => throw UnimplementedError(typeEl.text),
  //     };
  //     if (like > 0) {
  //       moments.update(momentId, (m) {
  //         if (!m.likes.contains(friendUser.qq)) m.likes.add(friendUser.qq);
  //         return m;
  //       });
  //     }

  //     // final commentEl = doc.querySelector(".comments-content.font-b");
  //     // if (commentEl != null) {
  //     //   final comment = commentEl.outerHtml;
  //     //   moments.update(momentId, (m) => m..comments.add(comment));
  //     // }

  //     final commentEls = doc.querySelectorAll(".comments-content");
  //     if (commentEls.isNotEmpty) {
  //       final comments = commentEls
  //           .map((it) {
  //             // link="nameCard_2358577552
  //             final sender = it.firstChild!.attributes["link"]!.split("_").last;
  //             final trailing = it.querySelector(".comments-op")!;
  //             final dateEl = trailing.querySelector(".ui-mr10.state")!;
  //             final date = dateEl.text;
  //             trailing.remove();

  //             final content = it.innerHtml;
  //             return Comment(sender: sender, content: content, date: date);
  //           })
  //           .toList(growable: false)
  //           .reversed;

  //       moments.update(momentId, (m) {
  //         for (final comment in comments) {
  //           if (!m.comments.any((item) => item.content == comment.content)) {
  //             m.comments.add(comment);
  //           }
  //         }

  //         return m;
  //       });
  //     }
  //   }

  //   // moments.values.forEach((e) {
  //   //   // print("id: ${e.id}");
  //   //   // print("content: ${e.content}");
  //   //   // print("comments: ${e.comments.length}");
  //   // });

  //   return ResponseMoment(
  //     moments: moments.values.where((it) => it.content.isNotEmpty).toList(growable: false),
  //     friends: users.values.toList(),
  //   );
  // }
}
