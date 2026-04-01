import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';

final uiSettingsProvider = StateNotifierProvider<UISettingsNotifier, double>((ref) {
  return UISettingsNotifier(ref);
});

final kgBarWeightProvider =
    StateNotifierProvider<BarWeightNotifier, double>((ref) {
      return BarWeightNotifier(ref, unit: 'kg');
    });

final lbBarWeightProvider =
    StateNotifierProvider<BarWeightNotifier, double>((ref) {
      return BarWeightNotifier(ref, unit: 'lbs');
    });

class UISettingsNotifier extends StateNotifier<double> {
  UISettingsNotifier(this._ref) : super(0.3) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    try {
      final repository = _ref.read(databaseRepositoryProvider);
      final opacity = await repository.fetchGlassOpacity();
      state = opacity;
    } catch (_) {
      // Default to 0.3 if error
      state = 0.3;
    }
  }

  Future<void> updateOpacity(double newValue) async {
    state = newValue;
    try {
      final repository = _ref.read(databaseRepositoryProvider);
      await repository.saveGlassOpacity(newValue);
    } catch (_) {
      // Ignore save error for UI responsiveness
    }
  }
}

class BarWeightNotifier extends StateNotifier<double> {
  BarWeightNotifier(this._ref, {required this.unit})
    : super(unit == 'lbs' ? 45 : 20) {
    _load();
  }

  final Ref _ref;
  final String unit;

  Future<void> _load() async {
    final repository = _ref.read(databaseRepositoryProvider);
    state = unit == 'lbs'
        ? await repository.fetchLbBarWeight()
        : await repository.fetchKgBarWeight();
  }

  Future<void> update(double value) async {
    state = value;
    final repository = _ref.read(databaseRepositoryProvider);
    if (unit == 'lbs') {
      await repository.saveLbBarWeight(value);
      return;
    }
    await repository.saveKgBarWeight(value);
  }
}
