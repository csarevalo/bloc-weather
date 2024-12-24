import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

void main() {
  group('Location', () {
    group('.fromJson()', () {
      test('returns correct Location object', () {
        final Map<String, dynamic> testLocationJson = {
          "results": [
            {
              "id": 5368361,
              "name": "Los Angeles",
              "latitude": 34.05223,
              "longitude": -118.24368,
              "elevation": 89.0,
              "feature_code": "PPLA2",
              "country_code": "US",
              "admin1_id": 5332921,
              "admin2_id": 5368381,
              "timezone": "America/Los_Angeles",
              "population": 3971883,
              "postcodes": ["90001", "90002", "90003"],
              "country_id": 6252001,
              "country": "United States",
              "admin1": "California",
              "admin2": "Los Angeles"
            }
          ],
          "generationtime_ms": 2.5769472,
        };
        expect(
          Location.fromJson(testLocationJson),
          isA<Location>()
              .having((loc) => loc.id, 'id', 5368361)
              .having((loc) => loc.city, 'city name', "Los Angeles")
              .having((loc) => loc.latitude, 'latitude', 34.05223)
              .having((loc) => loc.longitude, 'longitude', -118.24368)
              .having((loc) => loc.state, 'state name', "California")
              .having((loc) => loc.country, 'country name', "United States")
              .having((loc) => loc.countryCode, 'country code', "US"),
        );
      });
    });
  });
}
