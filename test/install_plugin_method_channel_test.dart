import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:install_plugin/install_plugin_method_channel.dart';

void main() {
  MethodChannelInstallPlugin platform = MethodChannelInstallPlugin();
  const MethodChannel channel = MethodChannel('install_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
