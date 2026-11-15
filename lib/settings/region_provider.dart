import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'watchRegion';

/// Used until the user picks another country.
const defaultRegion = 'AU';

typedef Region = ({String code, String name});

/// TMDB / JustWatch countries, A to Z. Add a line here for another country.
const regions = <Region>[
  (code: 'AR', name: 'Argentina'),
  (code: 'AU', name: 'Australia'),
  (code: 'AT', name: 'Austria'),
  (code: 'BE', name: 'Belgium'),
  (code: 'BR', name: 'Brazil'),
  (code: 'CA', name: 'Canada'),
  (code: 'CL', name: 'Chile'),
  (code: 'CO', name: 'Colombia'),
  (code: 'CZ', name: 'Czechia'),
  (code: 'DK', name: 'Denmark'),
  (code: 'EG', name: 'Egypt'),
  (code: 'FI', name: 'Finland'),
  (code: 'FR', name: 'France'),
  (code: 'DE', name: 'Germany'),
  (code: 'GR', name: 'Greece'),
  (code: 'HK', name: 'Hong Kong'),
  (code: 'HU', name: 'Hungary'),
  (code: 'IN', name: 'India'),
  (code: 'ID', name: 'Indonesia'),
  (code: 'IE', name: 'Ireland'),
  (code: 'IL', name: 'Israel'),
  (code: 'IT', name: 'Italy'),
  (code: 'JP', name: 'Japan'),
  (code: 'MY', name: 'Malaysia'),
  (code: 'MX', name: 'Mexico'),
  (code: 'NL', name: 'Netherlands'),
  (code: 'NZ', name: 'New Zealand'),
  (code: 'NO', name: 'Norway'),
  (code: 'PE', name: 'Peru'),
  (code: 'PH', name: 'Philippines'),
  (code: 'PL', name: 'Poland'),
  (code: 'PT', name: 'Portugal'),
  (code: 'RO', name: 'Romania'),
  (code: 'SA', name: 'Saudi Arabia'),
  (code: 'SG', name: 'Singapore'),
  (code: 'ZA', name: 'South Africa'),
  (code: 'KR', name: 'South Korea'),
  (code: 'ES', name: 'Spain'),
  (code: 'SE', name: 'Sweden'),
  (code: 'CH', name: 'Switzerland'),
  (code: 'TW', name: 'Taiwan'),
  (code: 'TH', name: 'Thailand'),
  (code: 'TR', name: 'Turkey'),
  (code: 'AE', name: 'United Arab Emirates'),
  (code: 'GB', name: 'United Kingdom'),
  (code: 'US', name: 'United States'),
];

/// "AU" -> "Australia". Unknown codes are shown as they are.
String regionName(String code) =>
    regions.where((r) => r.code == code).firstOrNull?.name ?? code;

/// The streaming country the user picked. Saved on the phone.
final regionProvider =
AsyncNotifierProvider<RegionNotifier, String>(RegionNotifier.new);

class RegionNotifier extends AsyncNotifier<String> {
  final _prefs = SharedPreferencesAsync();

  @override
  Future<String> build() async {
    final saved = await _prefs.getString(_key);
    if (saved != null && regions.any((r) => r.code == saved)) return saved;
    return defaultRegion;
  }

  Future<void> set(String code) async {
    state = AsyncData(code); // open pages reload at once
    await _prefs.setString(_key, code);
  }
}