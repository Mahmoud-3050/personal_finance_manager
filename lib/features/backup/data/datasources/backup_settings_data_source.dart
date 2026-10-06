import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/backup_settings.dart';

abstract interface class BackupSettingsStore {
  Future<BackupSettings> read();

  Future<void> write(BackupSettings settings);
}

class BackupSettingsDataSource implements BackupSettingsStore {
  BackupSettingsDataSource(this._preferences);

  final SharedPreferences _preferences;

  static const String scheduleKey = 'backup_schedule';
  static const String lastAttemptKey = 'backup_last_attempt';
  static const String lastSuccessKey = 'backup_last_success';
  static const String lastOutcomeKey = 'backup_last_outcome';
  static const String lastOriginKey = 'backup_last_origin';

  @override
  Future<BackupSettings> read() async {
    return BackupSettings(
      schedule:
          BackupSchedule.values.asNameMap()[_preferences.getString(
            scheduleKey,
          )] ??
          BackupSchedule.off,
      lastAttemptAt: _readDate(lastAttemptKey),
      lastSuccessAt: _readDate(lastSuccessKey),
      lastOutcome: BackupOutcome.values
          .asNameMap()[_preferences.getString(lastOutcomeKey)],
      lastOrigin: BackupOrigin.values
          .asNameMap()[_preferences.getString(lastOriginKey)],
    );
  }

  @override
  Future<void> write(BackupSettings settings) async {
    await _preferences.setString(scheduleKey, settings.schedule.name);
    await _writeDate(lastAttemptKey, settings.lastAttemptAt);
    await _writeDate(lastSuccessKey, settings.lastSuccessAt);
    await _writeName(lastOutcomeKey, settings.lastOutcome?.name);
    await _writeName(lastOriginKey, settings.lastOrigin?.name);
  }

  DateTime? _readDate(String key) {
    final String? raw = _preferences.getString(key);
    if (raw == null) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> _writeDate(String key, DateTime? value) async {
    if (value == null) {
      await _preferences.remove(key);
      return;
    }
    await _preferences.setString(key, value.toIso8601String());
  }

  Future<void> _writeName(String key, String? value) async {
    if (value == null) {
      await _preferences.remove(key);
      return;
    }
    await _preferences.setString(key, value);
  }
}
