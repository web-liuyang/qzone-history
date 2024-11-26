import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qzone/enviroment.dart';
import 'package:path/path.dart' as p;
import 'package:qzone/services/services.dart';

import 'repositories/entities/entities.dart';
import 'repositories/models/models.dart';
import 'repositories/repositories.dart';

final FriendRepository _friendRepository = FriendRepository(path: p.join(Environment.applicationCache.path, "friend.json"));
final LoginUserRepository _loginUserRepository = LoginUserRepository(path: p.join(Environment.applicationCache.path, "login_user.json"));
final MessageRepository _messageRepository = MessageRepository(path: p.join(Environment.applicationCache.path, "message.json"));
final MomentRepository _momentRepository = MomentRepository(path: p.join(Environment.applicationCache.path, "moment.json"));

late final FriendModel _friendModel;
late final LoginUserModel _loginUserModel;
late final MessageModel _messageModel;
late final MomentModel _momentModel;

final LoginService _loginService = LoginService(
  loginUserModel: _loginUserModel,
  userRepository: _loginUserRepository,
);

final MomentService _momentService = MomentService(
  friendModel: _friendModel,
  friendRepository: _friendRepository,
  loginUserModel: _loginUserModel,
  momentModel: _momentModel,
  momentRepository: _momentRepository,
  messageModel: _messageModel,
  messageRepository: _messageRepository,
);

class ProviderDecorator extends StatelessWidget {
  const ProviderDecorator({super.key, required this.child});

  final Widget child;

  static Future<void> ensureInitialized() async {
    final [
      friends as List<User>?,
      messages as List<Message>?,
      moments as List<Moment>?,
      user as LoginUser?,
    ] = await Future.wait([
      _friendRepository.read(),
      _messageRepository.read(),
      _momentRepository.read(),
      _loginUserRepository.read(),
    ]);

    _friendModel = FriendModel(friends ?? []);
    _messageModel = MessageModel(messages ?? []);
    _momentModel = MomentModel(moments ?? []);
    _loginUserModel = LoginUserModel(user);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _friendModel),
        ChangeNotifierProvider.value(value: _loginUserModel),
        ChangeNotifierProvider.value(value: _messageModel),
        ChangeNotifierProvider.value(value: _momentModel),
        //
        Provider<LoginService>(create: (context) => _loginService),
        Provider<MomentService>(create: (context) => _momentService),
      ],
      child: child,
    );
  }
}

// T getProvider<T>() {
//   return switch (T) {
//     LoginUserModel _ => _loginUserModel as T,
//     LoginUserRepository _ => _loginUserRepository as T,
//     LoginService _ => _loginService as T,
//     (_) => throw Exception("No such provider: $T"),
//   };
// }
