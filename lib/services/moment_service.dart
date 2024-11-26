import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:html/dom.dart' hide Comment;
import 'package:html/parser.dart';
import 'package:qzone/requests/requests.dart';

import '../repositories/entities/entities.dart';
import '../repositories/models/models.dart';
import '../repositories/repositories.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class MomentService {
  MomentService({
    required LoginUserModel loginUserModel,
    required MomentModel momentModel,
    required FriendModel friendModel,
    required MomentRepository momentRepository,
    required FriendRepository friendRepository,
    required MessageModel messageModel,
    required MessageRepository messageRepository,
  })  : _friendModel = friendModel,
        _friendRepository = friendRepository,
        _loginUserModel = loginUserModel,
        _momentModel = momentModel,
        _momentRepository = momentRepository,
        _messageModel = messageModel,
        _messageRepository = messageRepository;

  late final FriendModel _friendModel;

  late final FriendRepository _friendRepository;

  late final LoginUserModel _loginUserModel;

  late final MomentModel _momentModel;

  late final MomentRepository _momentRepository;

  late final MessageModel _messageModel;

  late final MessageRepository _messageRepository;

  Future<String> findAllMoment() async {
    return 'hello';
  }

  Future<String> findMoment() async {
    return 'hello';
  }

  Future<void> refreshMoments() async {
    if (_loginUserModel.user == null) {
      Toast.error("请先登录");
      return;
    }

    final LoginUser user = _loginUserModel.user!;

    List<String> htmls = [];

    final toastAction = Toast.loading("正在请求全部数据");
    try {
      htmls = await fetchAllMomentHTMLs();

      Toast.success("请求全部数据完成, 共有 ${htmls.length} 条数据");
    } on AppResponseStatus catch (status) {
      final String message = switch (status) {
        AppResponseStatus.expired => "用户数据已过期，请重新登录",
        AppResponseStatus.server => "服务器错误，请重新获取",
        (_) => throw ErrorDescription(""),
      };

      Toast.error(message);
      return;
    } catch (e) {
      Toast.error("获取数据失败");
      return;
    } finally {
      await Future.delayed(const Duration(milliseconds: 1));
      toastAction.dismiss();
    }

    final ToastAction toastAction1 = Toast.loading("准备解析数据(${htmls.length})");

    final qq = user.qq;
    final Map<String, Moment> toMoment = {};
    final Map<String, Message> toMessage = {};
    final Map<String, User> toUser = {};

    File("test/moments.html").writeAsStringSync("");

    for (int i = 0; i < htmls.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1));
      toastAction1.update("正在解析数据($i/${htmls.length})");

      final html = htmls[i];

      File("test/moments.html").writeAsStringSync(html, mode: FileMode.append);
      final doc = parse(html);

      final feedData = doc.querySelector("[name=feed_data]")!;
      final ownQQ = feedData.attributes["data-uin"]!;
      // 屏蔽不是自己的说说
      if (ownQQ != qq) continue;

      // 图片
      final imgEls = doc.querySelectorAll("img");
      for (final imgEl in imgEls) {
        final onloadText = imgEl.attributes["onload"];
        if (onloadText != null) {
          final match = RegExp(r"trueSrc:'(.+?)'", multiLine: true, dotAll: true).firstMatch(onloadText)!;
          final rawSrc = match[1]!;
          final index = rawSrc.indexOf("&ek");
          final src = index == -1 ? rawSrc : rawSrc.substring(0, index);
          imgEl.attributes["src"] = src.toString();
          imgEl.attributes.remove("onload");
        }
      }

      // 日期
      final dateEl = doc.querySelector(".info-detail .ui-mr8.state")!;
      final date = dateEl.text;

      // 好友
      final friendEl = doc.querySelector(".f-name.q_namecard")!;
      final friendUser = User(
        qq: friendEl.attributes["link"]!.split("_").last,
        nickname: friendEl.text,
      );
      toUser.putIfAbsent(friendUser.qq, () => friendUser);

      final id = feedData.attributes["data-tid"]!;
      final typeEl = doc.querySelector(".user-info .ui-mr10.state")!;
      void _ = switch (typeEl.text) {
        "赞了我的说说" => MomentServiceHelper.likeHandler(id: id, qq: friendUser.qq, doc: doc, moments: toMoment),
        "赞了" => MomentServiceHelper.likeHandler(id: id, qq: friendUser.qq, doc: doc, moments: toMoment),
        "评论" => MomentServiceHelper.commentHandler(id: id, doc: doc, moments: toMoment),
        "回复" => MomentServiceHelper.replyHandler(id: id, doc: doc, moments: toMoment),
        "送我礼物" => MomentServiceHelper.giftHandler(id: id, doc: doc, moments: toMoment),
        "给我留言" => MomentServiceHelper.messageHandler(
            id: id,
            qq: friendUser.qq,
            doc: doc,
            messages: toMessage,
            date: date,
          ),
        String() => throw UnimplementedError(typeEl.text),
      };
    }

    await Future.delayed(const Duration(milliseconds: 1));
    toastAction1.dismiss();

    Toast.success("解析数据完成");

    final List<User> friends = toUser.values.toList();
    await _friendRepository.create(friends);
    _friendModel.friends = friends;

    final List<Moment> moments = toMoment.values.where((it) => !it.content.isEmpty).toList(growable: false);
    await _momentRepository.create(moments);
    _momentModel.moments = moments;

    final List<Message> messages = toMessage.values.toList(growable: false);
    await _messageRepository.create(messages);
    _messageModel.messages = messages;

    await Future.delayed(const Duration(milliseconds: 1));

    Toast.success("应用数据完成");
  }

  Future<List<String>> fetchAllMomentHTMLs() async {
    final LoginUser user = _loginUserModel.user!;
    const count = 100;
    int pages = 131; // 64
    int totalPages = 1000;

    const maxTryCount = 5;
    int tryCount = 1;

    final List<String> result = [];

    while (true) {
      // debug 模式下使用
      if (pages > totalPages) {
        break;
      }

      if (tryCount > maxTryCount) {
        print("try count: $tryCount");
        throw AppResponseStatus.server;
      }

      print("request moments: $pages");
      final AppResponse<String> response = await requestRawMoments(user: user, pages: pages, count: count);
      // final AppResponse<String> response = await requestRawMomentsMock(user: user, pages: pages, count: count);
      // print(response.code);

      if (response.code == AppResponseStatus.server) {
        tryCount++;
        continue;
      }

      if (response.code == AppResponseStatus.expired) {
        throw AppResponseStatus.expired;
      }

      if (response.code == AppResponseStatus.empty) {
        break;
      }

      if (response.code == AppResponseStatus.success) {
        // File("test/moments/moments_$pages.txt").createSync(recursive: true);
        File("test/moments/moments_$pages.txt").writeAsStringSync(response.data);

        final body = response.data;
        String data = terseSpace(body);
        data = replaceHex(data);
        data = data.replaceAll(r"\", "");
        final htmls = extractHTML(data);

        result.addAll(htmls);
      }

      pages++;
    }

    return result;
  }
}

class MomentServiceHelper {
  // 说说
  static void momentHandler({
    required String id,
    required Document doc,
    required Map<String, Moment> moments,
  }) {
    moments.putIfAbsent(
      id,
      () => Moment(
        id: id,
        likes: [],
        content: const Content(images: [], videos: [], content: ""),
        comments: [],
      ),
    );

    final contentEl = doc.querySelector(".fui-left-right.f-ct-txtimg");
    if (contentEl != null) {
      final imgBoxEl = contentEl.children[0]; // first

      // 视频
      final List<String> videos = [];
      if (imgBoxEl.className.contains("f-video-wrap")) {
        final src = imgBoxEl.attributes["url3"]!.replaceAll("amp;", "");
        videos.add(src);
      }

      final imgEl = imgBoxEl.querySelector("img");
      final List<String> images = [];
      if (imgEl != null) {
        final src = imgEl.attributes["src"]!;
        // http://qzonestyle.gtimg.cn/qzone/space_item/pre/0/_1. // 无效的地址
        if (!src.endsWith(".")) images.add(src);
      }

      final txtBoxEl = contentEl.children[1]; // last
      // 自己发的说说
      final titleEl = txtBoxEl.querySelector(".txt-box-title.ellipsis-one");
      // 转发的说说
      final forwardedEl = txtBoxEl.querySelector(".txt-box-title.t-fixed");
      // 礼品卡 / 分享
      final innerEl = txtBoxEl.querySelector(".inner");

      String text = "";
      if (titleEl != null) {
        titleEl.nodes[0].remove(); // nickname
        titleEl.nodes[1].remove(); // :

        text = titleEl.innerHtml;

        if (text.startsWith("&nbsp;")) {
          text = text.replaceFirst("&nbsp;", "");
        }
      } else if (forwardedEl != null) {
        final titleEl = contentEl.previousElementSibling!.children[0];
        titleEl.nodes[0].remove(); // nickname

        text = titleEl.innerHtml;

        if (text.startsWith("&nbsp;")) {
          text = text.replaceFirst("&nbsp;", "");
        }

        // text += '''
        //   <div style="border: 1px solid #ccc;border-radius: 4px; padding: 0 20px; margin: 4px 0;">${forwardedEl.innerHtml}</div>
        // ''';
        text += forwardedEl.innerHtml;
      } else if (innerEl != null) {
        final isNotEmpty = innerEl.querySelector(".info.ellipsis-one")?.text.isNotEmpty ?? false;
        if (isNotEmpty) {
          text = innerEl.innerHtml;
        }
      } else {
        // print(contentEl.innerHtml);
        File("test/error.html").writeAsStringSync(doc.outerHtml);
        throw Exception("contentEl: $contentEl");
      }

      moments.update(id, (m) => m.copyWith(content: Content(images: images, videos: videos, content: text)));
    }

    final commentEls = doc.querySelectorAll(".comments-content");
    if (commentEls.isNotEmpty) {
      final comments = commentEls
          .map((it) {
            final sender = it.firstChild!.attributes["link"]!.split("_").last;
            final trailing = it.querySelector(".comments-op")!;
            final dateEl = trailing.querySelector(".ui-mr10.state")!;
            final date = dateEl.text;
            trailing.remove();

            final content = it.innerHtml;
            return Comment(sender: sender, content: content, date: date);
          })
          .toList(growable: false)
          .reversed;

      moments.update(id, (m) {
        for (final comment in comments) {
          if (!m.comments.any((item) => item.content == comment.content)) {
            m.comments.add(comment);
          }
        }

        return m;
      });
    }
  }

  ///赞
  static void likeHandler({
    required String id,
    required String qq,
    required Document doc,
    required Map<String, Moment> moments,
  }) {
    MomentServiceHelper.momentHandler(id: id, doc: doc, moments: moments);
    moments.update(id, (m) {
      if (!m.likes.contains(qq)) m.likes.add(qq);
      return m;
    });
  }

  ///评论
  static void commentHandler({
    required String id,
    required Document doc,
    required Map<String, Moment> moments,
  }) {
    MomentServiceHelper.momentHandler(id: id, doc: doc, moments: moments);
  }

  /// 回复
  static void replyHandler({
    required String id,
    required Document doc,
    required Map<String, Moment> moments,
  }) {
    MomentServiceHelper.momentHandler(id: id, doc: doc, moments: moments);
  }

  /// 礼物
  static void giftHandler({
    required String id,
    required Document doc,
    required Map<String, Moment> moments,
  }) {
    MomentServiceHelper.momentHandler(id: id, doc: doc, moments: moments);
  }

  /// 留言
  static void messageHandler({
    required String id,
    required Document doc,
    required Map<String, Message> messages,
    required String qq,
    required String date,
  }) {
    final contentEl = doc.querySelector(".txt-box-title.ellipsis-one");
    if (contentEl != null) {
      contentEl.children[0].remove(); // nickname
      contentEl.children[0].remove(); // 留言
      contentEl.children[0].remove(); // :
      String content = contentEl.innerHtml.trim();

      if (content.startsWith("<!--?cs#后台不会下发留言人，只会下发内容，模板里自己补齐?-->")) {
        content = content.replaceFirst("<!--?cs#后台不会下发留言人，只会下发内容，模板里自己补齐?-->", "").trim();
      }

      if (content.startsWith("&nbsp;")) {
        content = content.replaceFirst("&nbsp;", "").trim();
      }

      // messages.update(id, (m) => m.copyWith(content: content, date: date,sender: qq));
      messages.putIfAbsent(id, () => Message(sender: qq, content: content, date: date));
    }
  }
}
