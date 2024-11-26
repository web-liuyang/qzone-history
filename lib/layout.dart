import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qzone/footer.dart';
import 'package:qzone/header.dart';
import 'package:qzone/repositories/models/models.dart';
import 'package:qzone/widgets/widgets.dart';

import 'friend_view.dart';
import 'message_view.dart';
import 'moment_view.dart';

BuildContext get rootContext => _rootContext;
late BuildContext _rootContext;

class TabContent {
  final Widget tab;
  final Widget view;

  TabContent({required this.tab, required this.view});
}

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  _LayoutState createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    _rootContext = context;

    final tabContents = [
      TabContent(
        tab: Tab(
          child: Selector<MomentModel, int>(
            selector: (context, model) => model.moments.length,
            builder: (context, value, child) => Text("说说 ($value)"),
          ),
        ),
        view: MomentView(),
      ),
      TabContent(
        tab: Tab(
          child: Selector<FriendModel, int>(
            selector: (context, model) => model.friends.length,
            builder: (context, value, child) => Text("好友 ($value)"),
          ),
        ),
        view: SizedBox.expand(child: FriendView()),
      ),
      TabContent(
        tab: Tab(
          child: Selector<MessageModel, int>(
            selector: (context, model) => model.messages.length,
            builder: (context, value, child) => Text("留言 ($value)"),
          ),
        ),
        view: MessageView(),
      ),
    ];

    return Scaffold(
      body: Column(
        children: [
          Header(),
          const Divider(),
          Expanded(
            child: DefaultTabController(
              length: tabContents.length,
              child: SpacedWidget(
                children: [
                  TabBar(
                    tabs: [for (final tab in tabContents) tab.tab],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [for (final tab in tabContents) tab.view],
                    ),
                  )
                ],
              ),
            ),
          ),
          const Divider(),
          Footer()
        ],
      ),
    );
  }
}
