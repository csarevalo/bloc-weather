import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

void main() {
  group('Weather', () {
    group('.fromJson()', () {
      test('returns correct Weather object', () {
        final testWeatherJson = {
          "latitude": 34.060257,
          "longitude": -118.23433,
          "generationtime_ms": 0.05793571472167969,
          "utc_offset_seconds": 0,
          "timezone": "GMT",
          "timezone_abbreviation": "GMT",
          "elevation": 91.0,
          "current_weather_units": {
            "time": "iso8601",
            "interval": "seconds",
            "temperature": "°C",
            "windspeed": "km/h",
            "winddirection": "°",
            "is_day": "",
            "weathercode": "wmo code"
          },
          "current_weather": {
            "time": "2024-12-15T20:45",
            "interval": 900,
            "temperature": 17.7,
            "windspeed": 5.0,
            "winddirection": 159,
            "is_day": 1,
            "weathercode": 0
          }
        };
        expect(
          Weather.fromJson(testWeatherJson),
          isA<Weather>()
              .having((w) => w.temperature, 'temperature', 17.7)
              .having((w) => w.units, 'temperature units', "°C")
              .having((w) => w.weatherCode, 'weather code', 0)
              .having((w) => w.lastUpdated, "when weather was last update",
                  DateTime.parse("2024-12-15T20:45"))
              .having((w) => w.timezone, 'timezone', "GMT"),
        );
      });
    });
  });
}
