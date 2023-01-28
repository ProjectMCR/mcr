import 'package:hive/hive.dart';

class SettingsRepository {
  SettingsRepository._();

  static final instance = SettingsRepository._();
  Future<void> init() async {
    settingsBox = await Hive.openBox<bool>('settings');
  }

  Future<void> putOffline(bool value) async {
    settingsBox.put('offline', value);
  }

  bool getOffline() {
    return settingsBox.get('offline') ?? false;
  }

  Future<void> putHasAssets(bool value) async {
    settingsBox.put('hasAssets', value);
  }

  bool getHasAssets() {
    return settingsBox.get('hasAssets') ?? false;
  }

  late Box<bool> settingsBox;
}
