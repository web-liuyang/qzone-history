import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qzone/repositories/models/models.dart';
import 'package:qzone/widgets/widgets.dart';

import 'repositories/entities/entities.dart';

class _SearchSetting {
  final bool qq;
  final bool nickname;
  final bool exact;
  final bool ignoreCase;

  _SearchSetting({
    required this.qq,
    required this.nickname,
    required this.exact,
    required this.ignoreCase,
  });

  _SearchSetting copyWith({
    bool? qq,
    bool? nickname,
    bool? exact,
    bool? ignoreCase,
  }) {
    return _SearchSetting(
      qq: qq ?? this.qq,
      nickname: nickname ?? this.nickname,
      exact: exact ?? this.exact,
      ignoreCase: ignoreCase ?? this.ignoreCase,
    );
  }
}

class FriendView extends StatefulWidget {
  const FriendView({super.key});

  @override
  State<FriendView> createState() => _FriendViewState();
}

class _FriendViewState extends State<FriendView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String searchText = "";
  _SearchSetting searchSetting = _SearchSetting(qq: true, nickname: false, exact: false, ignoreCase: true);
  bool showSearchSetting = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final FriendModel friendModel = context.watch<FriendModel>();

    final friends = friendModel.friends.where((item) {
      if (searchText.isEmpty) return true;
      if (searchSetting.qq && matchIndex(item.qq, searchText, ignoreCase: searchSetting.ignoreCase, exactMatch: searchSetting.exact).isNotEmpty) return true;
      if (searchSetting.nickname && matchIndex(item.nickname, searchText, ignoreCase: searchSetting.ignoreCase, exactMatch: searchSetting.exact).isNotEmpty) {
        return true;
      }

      return false;
    });

    return SpacedWidget(
      children: [
        TextField(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 12),
            hintText: "搜索QQ/昵称",
            suffixIcon: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                setState(() => showSearchSetting = !showSearchSetting);
              },
            ),
            suffixIconColor: showSearchSetting ? Theme.of(context).primaryColor : null,
          ),
          onChanged: (value) {
            setState(() => searchText = value);
          },
        ),
        if (showSearchSetting)
          OverflowBar(
            children: [
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text("QQ"),
                value: searchSetting.qq,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => searchSetting = searchSetting.copyWith(qq: value));
                },
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Text("Nickname"),
                value: searchSetting.nickname,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => searchSetting = searchSetting.copyWith(nickname: value));
                },
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Text("Exact"),
                value: searchSetting.exact,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => searchSetting = searchSetting.copyWith(exact: value));
                },
              ),
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Text("Ignore Case"),
                value: searchSetting.ignoreCase,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => searchSetting = searchSetting.copyWith(ignoreCase: value));
                },
              ),
              const Divider()
            ],
          ),
        Expanded(
          child: ListView.builder(
            itemCount: friends.length,
            itemBuilder: (context, index) {
              final friend = friends.elementAt(index);

              return Card(
                child: NumberedContainer(
                  number: index + 1,
                  child: ListTile(
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
                    title: TextMatch(friend.nickname, searchText, exactMatch: searchSetting.exact),
                    subtitle: TextMatch("QQ: ${friend.qq}", searchText, exactMatch: searchSetting.exact),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FriendViewCard extends StatelessWidget {
  const FriendViewCard({
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
