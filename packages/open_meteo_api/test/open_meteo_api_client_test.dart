import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:test/test.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('OpenMeteoApiClient', () {
    late http.Client httpClient;
    late OpenMeteoApiClient apiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      apiClient = OpenMeteoApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(OpenMeteoApiClient(), isNotNull);
      });
    });

    group('.getLocation()', () {
      const query = 'mock-query';

      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.getLocation(query);
        } catch (_) {}
        verify(
          () => httpClient.get(Uri.https(
            'geocoding-api.open-meteo.com',
            '/v1/search',
            {'name': query, 'count': '1'},
          )),
        ).called(1);
      });

      test('throws LocationRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => apiClient.getLocation(query),
          throwsA(isA<LocationRequestFailure>()),
        );
      });

      test('throws LocationNotFoundFailure on error response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await expectLater(
          apiClient.getLocation(query),
          throwsA(isA<LocationNotFoundFailure>()),
        );
      });

      test('throws LocationNotFoundFailure on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{"results": []}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await expectLater(
          apiClient.getLocation(query),
          throwsA(isA<LocationNotFoundFailure>()),
        );
      });

      test('returns Location on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('''
{
  "results": [
    {
      "id": 5368361,
      "name": "Los Angeles",
      "latitude": 34.05223,
      "longitude": -118.24368,
      "elevation": 89,
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
  "generationtime_ms": 1.3049841
}
        ''');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final actual = await apiClient.getLocation(query);
        expect(
          actual,
          isA<Location>()
              .having((l) => l.id, 'id', 5368361)
              .having((l) => l.city, 'city name', 'Los Angeles')
              .having((l) => l.latitude, 'latitude', 34.05223)
              .having((l) => l.longitude, 'longitude', -118.24368)
              .having((l) => l.state, 'state name', "California")
              .having((l) => l.country, 'country name', "United States")
              .having((l) => l.countryCode, 'country code', "US"),
        );
      });
    });

    group('.getWeather()', () {
      const latitude = 34.060257;
      const longitude = -118.23433;

      test(' makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await apiClient.getWeather(latitude: latitude, longitude: longitude);
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.https('api.open-meteo.com', 'v1/forecast', {
              'latitude': '$latitude',
              'longitude': '$longitude',
              'current_weather': 'true',
            }),
          ),
        ).called(1);
      });

      test(' throws WeatherRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => apiClient.getWeather(
            latitude: latitude,
            longitude: longitude,
          ),
          throwsA(isA<WeatherRequestFailure>()),
        );
      });

      test(' throws WeatherNotFoundFailure on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => apiClient.getWeather(
            latitude: latitude,
            longitude: longitude,
          ),
          throwsA(isA<WeatherNotFoundFailure>()),
        );
      });

      test(' returns weather on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''
{
  "latitude": 34.060257,
  "longitude": -118.23433,
  "generationtime_ms": 0.079035758972168,
  "utc_offset_seconds": 0,
  "timezone": "GMT",
  "timezone_abbreviation": "GMT",
  "elevation": 91,
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
    "time": "2024-12-16T00:45",
    "interval": 900,
    "temperature": 14.6,
    "windspeed": 8.7,
    "winddirection": 275,
    "is_day": 1,
    "weathercode": 0
  }
}
        ''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final actual = await apiClient.getWeather(
          latitude: latitude,
          longitude: longitude,
        );
        expect(
          actual,
          isA<Weather>()
              .having((w) => w.temperature, 'temperature', 14.6)
              .having((w) => w.units, 'temperature units', "°C")
              .having((w) => w.weatherCode, 'weatherCode', 0)
              .having((w) => w.lastUpdated, 'whe weather was last updated',
                  DateTime.parse("2024-12-16T00:45"))
              .having((w) => w.timezone, 'timezone', "GMT"),
        );
      });
    });
  });
}
