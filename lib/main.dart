import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:qzone/enviroment.dart';
import 'package:qzone/layout.dart';
import 'package:qzone/provider_decorator.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.ensureInitialized();
  await ProviderDecorator.ensureInitialized();
  MediaKit.ensureInitialized();

  print(Environment.temporary.path);
  print(Environment.applicationSupport.path);
  print(Environment.applicationDocuments.path);
  print(Environment.applicationCache.path);
  // print(Environment.downloads.path);

  runApp(const QQZoneApplication());
}

class QQZoneApplication extends StatelessWidget {
  const QQZoneApplication({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(const RoundedRectangleBorder()),
          textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12)),
        ),
      ),
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
        space: 0,
      ),
    );

    return ToastificationWrapper(
      config: ToastificationConfig(animationDuration: Duration(milliseconds: 300)),
      child: MaterialApp(
        title: 'QQ Zone',
        theme: theme,
        home: ProviderDecorator(
          child: Layout(),
        ),
        shortcuts: {
          SingleActivator(LogicalKeyboardKey.keyS, meta: true): VoidCallbackIntent(
            () async {
              print("save ");
              print(HardwareKeyboard.instance.logicalKeysPressed);

              final FileSaveLocation? file = await getSaveLocation(
                acceptedTypeGroups: [
                  // XTypeGroup(extensions: [ext])
                ],
              );

              if (file == null) return null;
            },
          ),
        },
      ),
    );
  }
}
