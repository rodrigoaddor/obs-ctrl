import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:obs_ctrl/data/obs.dart';
import 'package:obs_websocket/obs_websocket.dart';

class ConnectPage extends HookConsumerWidget {
  const ConnectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hostController = useTextEditingController();

    void handleConnect(BuildContext context) async {
      try {
        ref.read(obsProvider.notifier).state = await ObsWebSocket.connect(
          connectUrl: 'ws://${hostController.text}:4444',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect'),
      ),
      body: Builder(
        builder: (context) => Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: hostController,
                decoration: const InputDecoration(
                  labelText: 'Host',
                  hintText: 'localhost',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                child: const Text('Connect'),
                onPressed: () => handleConnect(context),
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                    theme.textTheme.button!.copyWith(fontSize: 16),
                  ),
                  fixedSize: MaterialStateProperty.all(
                    const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
