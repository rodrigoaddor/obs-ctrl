import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:obs_ctrl/data/obs.dart';
import 'package:obs_websocket/obs_websocket.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);

    final obs = ref.watch(obsProvider.state);
    final currentScene = useState<String>('');
    final scenes = useState<List<String>>([]);

    final wrapAround = useState<bool>(false);
    void handleWrapAround(bool value) {
      wrapAround.value = value;
    }

    void handleConnect() {
      ref.read(obsProvider.state).state = null;
    }

    final hasPrevious = scenes.value.indexOf(currentScene.value) > 0 || wrapAround.value;
    final hasNext = scenes.value.indexOf(currentScene.value) < scenes.value.length - 1 || wrapAround.value;

    void handlePrevious() {
      int previousIndex = scenes.value.indexOf(currentScene.value) - 1;
      if (previousIndex < 0 && wrapAround.value) {
        previousIndex = scenes.value.length - 1;
      } else if (previousIndex < 0) {
        return;
      }

      obs.state?.setCurrentScene(scenes.value[previousIndex]);
    }

    void handleNext() {
      int nextIndex = scenes.value.indexOf(currentScene.value) + 1;
      if (nextIndex > scenes.value.length - 1 && wrapAround.value) {
        nextIndex = 0;
      } else if (nextIndex > scenes.value.length - 1) {
        return;
      }

      obs.state?.setCurrentScene(scenes.value[nextIndex]);
    }

    useEffect(() {
      obs.state?.command('GetSceneList').then((res) {
        if (res == null) return;

        currentScene.value = res.rawResponse['current-scene'] as String;
        scenes.value =
            (res.rawResponse['scenes'] as List<dynamic>).map((e) => e['name'] as String).toList(growable: false);
      });

      obs.state?.addFallbackListener((BaseEvent event) {
        if (event.updateType == 'SwitchScenes') {
          currentScene.value = event.rawEvent['scene-name'];
        }
      });
    }, []);

    final buttonStyle = ButtonStyle(
      textStyle: MaterialStateProperty.all(
        theme.textTheme.button!.copyWith(fontSize: 48),
      ),
      fixedSize: MaterialStateProperty.all(
        Size.fromHeight((media.size.height - media.viewPadding.vertical) * 0.25),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('OBS Ctrl'),
        actions: [
          TextButton(
            child: const Text('Connect'),
            onPressed: handleConnect,
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              'Current Scene: ${currentScene.value}',
              textAlign: TextAlign.center,
            ),
          ),
          SwitchListTile(
            title: const Text('Wrap Around'),
            value: wrapAround.value,
            onChanged: handleWrapAround,
          ),
          const Expanded(child: SizedBox.shrink()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              child: const Text('Previous'),
              onPressed: hasPrevious ? handlePrevious : null,
              style: buttonStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              child: const Text('Next'),
              onPressed: hasNext ? handleNext : null,
              style: buttonStyle,
            ),
          ),
        ],
      ),
    );
  }
}
