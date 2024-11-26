import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import 'package:qzone/repositories/models/models.dart';
import 'package:qzone/utils/utils.dart';
import 'package:qzone/widgets/widgets.dart';

import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.

import 'repositories/entities/entities.dart';
import 'services/services.dart';

class MomentView extends StatefulWidget {
  const MomentView({super.key});

  @override
  State<MomentView> createState() => _MomentViewState();
}

class _MomentViewState extends State<MomentView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final Map<String, VideoController> toVideoController = {};

  // final player = Player();

  @override
  void initState() {
    // player.open(
    //   Media('https://user-images.githubusercontent.com/28951144/253067794-73b5ca5d-e90d-4892-bc09-2a80f05c9f0b.mp4'),
    //   play: false,
    // );

    super.initState();
  }

  @override
  void dispose() {
    // player.dispose();
    super.dispose();
  }

  // void startBackgroundTask() async {
  //   // 将前面提到的代码封装到这里
  //   final isolateNameServer = IsolateNameServer();
  //   final name = 'background_isolate';
  //   final uri = Uri.parse('isolate://$name');

  //   Isolate.run(() {});

  //   final receivePort = ReceivePort();
  //   isolateNameServer.registerUri(name, uri);

  //   await Isolate.spawnUri(uri, [], backgroundTask, onExit: receivePort.sendPort);

  //   // 监听来自后台Isolate的消息
  //   receivePort.listen((message) {
  //     print('收到消息：$message');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final MomentService momentService = context.read<MomentService>();
    final MomentModel momentModel = context.watch<MomentModel>();

    return SpacedWidget(
      children: [
        TextButton(
          onPressed: () async {
            // final t = Toast.loading("Test1");
            // int count = 0;

            // final timer = Timer.periodic(const Duration(seconds: 1), (timer) {
            //   t.update("i: $count");
            // });

            // Thread.run<int>(
            //   (send) async {
            //     print(t);
            //     for (int i = 0; i < 1000000; i++) {
            //       send(i);
            //     }
            //   },
            //   onEvent: (message) {
            //     count = message;
            //   },
            //   onDone: () {
            //     timer.cancel();
            //     t.update("已完成");
            //   },
            // );

            // print("Over");

            await momentService.refreshMoments();
            print("OVER");
          },
          child: Text("刷新说说"),
        ),
        if (momentModel.moments.isEmpty) Text("暂无说说"),
        Expanded(
          child: ListView.builder(
            itemCount: momentModel.moments.length,
            itemBuilder: (context, index) {
              final moment = momentModel.moments[index];

              for (final video in moment.content.videos) {
                final player = Player()
                  ..open(
                    // Media('https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4'),
                    Media(video),
                    play: false,
                  );

                toVideoController.putIfAbsent(video, () => VideoController(player));
              }
              return MomentCard(
                index: index,
                moment: moment,
                getVideoController: (String video) {
                  return toVideoController[video]!;
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class MomentCard extends StatelessWidget {
  const MomentCard({
    super.key,
    required this.index,
    required this.moment,
    required this.getVideoController,
  });

  final int index;
  final Moment moment;
  final VideoController Function(String video) getVideoController;

  @override
  Widget build(BuildContext context) {
    final loginUserModel = context.watch<LoginUserModel>();
    final loginUser = loginUserModel.user;
    final friendModel = context.watch<FriendModel>();
    final friends = friendModel.friends;
    final likes = moment.likes;
    // print("moment id: ${moment.id}");

    final Iterable<User> likeUsers = likes.map((qq) {
      if (qq == loginUser?.qq) return loginUser!;
      return friends.firstWhere((item) => item.qq == qq);
    });

    final comments = moment.comments.toList(growable: false).reversed;

    final theme = Theme.of(context);

    final dateTextStyle = theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Card(
      margin: const EdgeInsets.all(8),
      child: NumberedContainer(
        number: index + 1,
        child: SpacedWidget(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              child: SpacedWidget(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HtmlWidget(
                    moment.content.content,
                  ),
                  if (moment.content.videos.isEmpty)
                    ...moment.content.images.map(
                      (src) => Image.network(
                        src,
                        // width: 200,
                        // height: 200,
                        // fit: BoxFit.cover,
                      ),
                    ),
                  ...moment.content.videos.map(
                    (src) {
                      return Video(
                        controller: getVideoController(src),
                        width: 400,
                        height: 200,
                      );
                    },
                  ),
                ],
              ),
            ),
            if (likeUsers.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Container(margin: EdgeInsets.only(right: 8), child: const Icon(Icons.thumb_up)),
                    if (likeUsers.length > 3) ...[
                      Text("${likeUsers.elementAt(0).nickname}、"),
                      Text("${likeUsers.elementAt(1).nickname}、"),
                      Text(likeUsers.elementAt(2).nickname),
                      Text("等${likeUsers.length}人觉得很赞")
                    ] else ...[
                      for (final user in likeUsers) Text("${user.nickname}${likeUsers.last != user ? "、" : ""}"),
                      Text("觉得很赞")
                    ],
                  ],
                ),
              ),
            if (comments.isNotEmpty) ...[
              const Divider(),
              for (final comment in comments)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: SpacedWidget(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HtmlWidget(comment.content),
                      Text(comment.date, style: dateTextStyle),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
