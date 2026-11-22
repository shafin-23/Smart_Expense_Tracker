import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final String profileName;
  final String currency;

  const AppPreferences({
    this.profileName = 'Shafin',
    this.currency = 'BDT (৳)',
  });

  String get currencySymbol {
    switch (currency) {
      case 'USD (\$)':
        return '\$';
      case 'EUR (€)':
        return '€';
      case 'GBP (£)':
        return '£';
      case 'INR (₹)':
        return '₹';
      case 'BDT (৳)':
      default:
        return '৳';
    }
  }

  AppPreferences copyWith({
    String? profileName,
    String? currency,
  }) {
    return AppPreferences(
      profileName: profileName ?? this.profileName,
      currency: currency ?? this.currency,
    );
  }
}

final appPreferencesProvider =
NotifierProvider<AppPreferencesNotifier, AppPreferences>(
  AppPreferencesNotifier.new,
);

class AppPreferencesNotifier extends Notifier<AppPreferences> {
  bool _loaded = false;

  @override
  AppPreferences build() {
    if (!_loaded) {
      _loaded = true;
      Future.microtask(loadPreferences);
    }

    return const AppPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    state = AppPreferences(
      profileName: prefs.getString('profile_name') ?? 'Shafin',
      currency: prefs.getString('currency') ?? 'BDT (৳)',
    );
  }

  Future<void> updateProfileName(String name) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('profile_name', name);

    state = state.copyWith(profileName: name);
  }

  Future<void> updateCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('currency', currency);

    state = state.copyWith(currency: currency);
  }
}