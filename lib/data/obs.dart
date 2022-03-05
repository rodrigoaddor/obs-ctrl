import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:obs_websocket/obs_websocket.dart';

final obsProvider = StateProvider<ObsWebSocket?>((ref) => null);
