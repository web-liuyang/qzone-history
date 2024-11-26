import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:qzone/repositories/models/models.dart';
import 'package:qzone/widgets/widgets.dart';

import 'repositories/entities/entities.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final MessageModel messageModel = context.watch<MessageModel>();
    final messages = messageModel.messages;

    return SpacedWidget(
      children: [
        if (messages.isEmpty) Text("暂无留言"),
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages.elementAt(index);

              return MessageCard(index: index, message: message);
            },
          ),
        ),
      ],
    );
  }
}

class MessageViewCard extends StatelessWidget {
  const MessageViewCard({
    super.key,
    required this.match,
    required this.friend,
  });

  final String match;

  final User friend;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipPath(
        clipper: const ShapeBorderClipper(shape: CircleBorder()),
        child: Image.network(
          friend.avatar,
          width: 48,
          height: 48,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person);
          },
        ),
      ),
      title: TextMatch(friend.nickname, match),
      subtitle: TextMatch("QQ: ${friend.qq}", match),
    );
  }
}

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.index,
    required this.message,
  });

  final int index;
  final Message message;

  @override
  Widget build(BuildContext context) {
    final loginUserModel = context.watch<LoginUserModel>();
    final loginUser = loginUserModel.user;
    final friendModel = context.watch<FriendModel>();
    final friend = message.sender == loginUser?.qq ? loginUser! : friendModel.friends.firstWhere((item) => item.qq == message.sender);

    final theme = Theme.of(context);
    final dateTextStyle = theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Card(
      margin: const EdgeInsets.all(8),
      child: NumberedContainer(
        number: index + 1,
        child: SpacedWidget(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: ClipPath(
                clipper: const ShapeBorderClipper(shape: CircleBorder()),
                child: Image.network(
                  friend.avatar,
                  width: 48,
                  height: 48,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.person);
                  },
                ),
              ),
              title: Text(friend.nickname),
              subtitle: Text(message.date, style: dateTextStyle),
            ),
            Container(
              padding: EdgeInsets.all(12),
              child: HtmlWidget(
                message.content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
