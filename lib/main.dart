import 'package:dartnative/dartnative.dart';

import 'dartnative_plugin_registrant.dart';

// iOS: a plugin (or the app) can't receive the URL an app is opened with.
// Info.plist registers the `dnscenerepro` scheme. With the app running:
//
//   xcrun simctl openurl booted 'dnscenerepro://claim?code=AB12'
//
// The app comes to the front and the lifecycle events below arrive, but the
// URL never reaches Dart or any plugin: `DartNativeSceneDelegate` implements
// only scene(_:willConnectTo:options:), and plugins have no registrar or
// listener for scene(_:openURLContexts:) / scene(_:continue:). Android has
// DNActivityEvents.addIntentListener for the same thing.
void main() {
  DartNativePluginRegistrant.registerAll();
  runApp(const SceneEventsRepro());
}

const _ink = TextStyle(color: Color(0xFF111111), fontSize: 16);

class SceneEventsRepro extends StatefulWidget {
  const SceneEventsRepro({super.key});

  @override
  State<SceneEventsRepro> createState() => _SceneEventsReproState();
}

class _SceneEventsReproState extends State<SceneEventsRepro>
    with WidgetsBindingObserver {
  final List<String> _events = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _events.add('lifecycle: ${state.name}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Open dnscenerepro://claim?code=AB12',
              style: TextStyle(color: Color(0xFF111111), fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Expected: the URL reaches the app (a plugin can listen for it).', style: _ink),
            const Text('Actual: no API delivers it; only lifecycle events arrive.', style: _ink),
            const SizedBox(height: 16),
            const Text('URLs received: none (no API to receive one)', style: _ink),
            const SizedBox(height: 16),
            for (final e in _events) Text(e, style: _ink),
          ],
        ),
      ),
    );
  }
}
