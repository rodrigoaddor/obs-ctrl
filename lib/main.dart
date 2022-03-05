import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:obs_ctrl/data/obs.dart';
import 'package:obs_ctrl/pages/connect.dart';
import 'package:obs_ctrl/pages/home.dart';

void main() async {
  runApp(
    const ProviderScope(
      child: ObsCtrlApp(),
    ),
  );
}

class ObsCtrlApp extends HookConsumerWidget {
  const ObsCtrlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obs = ref.watch(obsProvider.state);

    return MaterialApp(
      title: 'OBS Ctrl',
      home: obs.state != null ? const HomePage() : const ConnectPage(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}
