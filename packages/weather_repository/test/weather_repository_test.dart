import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart' as open_meteo_api;
import 'package:test/test.dart';
import 'package:weather_repository/weather_repository.dart';

class MockOpenMeteoApiClient extends Mock
    implements open_meteo_api.OpenMeteoApiClient {}

class MockLocation extends Mock implements open_meteo_api.Location {}

class MockWeather extends Mock implements open_meteo_api.Weather {}

void main() {
  group('Weather Repository', () {
    late MockOpenMeteoApiClient weatherApiClient;
    late WeatherRepository weatherRepository;

    setUp(() {
      weatherApiClient = MockOpenMeteoApiClient();
      weatherRepository = WeatherRepository(weatherApiClient: weatherApiClient);
    });

    group('constructor', () {
      test('instantiates internal weather api client when not injected', () {
        expect(WeatherRepository(), isNotNull);
      });
    });

    group('.getWeather()', () {
      final Location testLocation = Location(
        city: 'Los Angeles',
        state: 'California',
        country: 'United States',
        countryCode: 'US',
      );
      const double latitude = 34.05223;
      const double longitude = -118.24368;
      final double testTemperature = 70.0;

      test("calls api's getLocation with correction location/city name",
          () async {
        try {
          await weatherRepository.getWeather(testLocation.city);
        } catch (_) {}
        verify(() => weatherApiClient.getLocation(testLocation.city)).called(1);
      });

      test("throws exception when api's getLocation fails", () {
        final exception = Exception('oops');
        when(() => weatherApiClient.getLocation(any())).thenThrow(exception);
        expect(
          () async => await weatherRepository.getWeather(testLocation.city),
          throwsA(exception),
        );
      });

      test("calls api's getWeather with the correct latitude and longitude",
          () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weatherApiClient.getLocation(any())).thenAnswer(
          (_) async => location,
        );
        try {
          await weatherRepository.getWeather(testLocation.city);
        } catch (_) {}
        verify(
          () => weatherApiClient.getWeather(
            latitude: latitude,
            longitude: longitude,
          ),
        ).called(1);
      });

      test('throws exception when .getWeather() fails', () {
        final exception = Exception('oops');
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => weatherApiClient.getLocation(any()))
            .thenAnswer((_) async => location);
        when(
          () => weatherApiClient.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenThrow(exception);
        expect(
          () => weatherRepository.getWeather(testLocation.city),
          throwsA(exception),
        );
      });

      test('returns correct weather on success (clear)', () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.city).thenReturn(testLocation.city);
        when(() => location.state).thenReturn(testLocation.state);
        when(() => location.country).thenReturn(testLocation.country);
        when(() => location.countryCode).thenReturn(testLocation.countryCode);
        final weather = MockWeather();
        final int testWeatherCode = 0; //WeatherCondition.clear
        final WeatherCondition testWeatherCondition = WeatherCondition.clear;
        when(() => weather.temperature).thenReturn(testTemperature);
        when(() => weather.weatherCode).thenReturn(testWeatherCode);
        when(() => weatherApiClient.getLocation(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude')),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(testLocation.city);
        expect(
          actual,
          Weather(
            temperature: testTemperature,
            location: testLocation,
            condition: testWeatherCondition,
          ),
        );
      });

      test('returns correct weather on success (cloudy)', () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.city).thenReturn(testLocation.city);
        when(() => location.state).thenReturn(testLocation.state);
        when(() => location.country).thenReturn(testLocation.country);
        when(() => location.countryCode).thenReturn(testLocation.countryCode);
        final weather = MockWeather();
        final int testWeatherCode = 48; //WeatherCondition.cloudy
        final WeatherCondition testWeatherCondition = WeatherCondition.cloudy;
        when(() => weather.temperature).thenReturn(testTemperature);
        when(() => weather.weatherCode).thenReturn(testWeatherCode);
        when(() => weatherApiClient.getLocation(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude')),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(testLocation.city);
        expect(
          actual,
          Weather(
            temperature: testTemperature,
            location: testLocation,
            condition: testWeatherCondition,
          ),
        );
      });

      test('returns correct weather on success (rainy)', () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.city).thenReturn(testLocation.city);
        when(() => location.state).thenReturn(testLocation.state);
        when(() => location.country).thenReturn(testLocation.country);
        when(() => location.countryCode).thenReturn(testLocation.countryCode);
        final weather = MockWeather();
        final int testWeatherCode = 61; //WeatherCondition.rainy
        final WeatherCondition testWeatherCondition = WeatherCondition.rainy;
        when(() => weather.temperature).thenReturn(testTemperature);
        when(() => weather.weatherCode).thenReturn(testWeatherCode);
        when(() => weatherApiClient.getLocation(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude')),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(testLocation.city);
        expect(
          actual,
          Weather(
            temperature: testTemperature,
            location: testLocation,
            condition: testWeatherCondition,
          ),
        );
      });

      test('returns correct weather on success (snowy)', () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.city).thenReturn(testLocation.city);
        when(() => location.state).thenReturn(testLocation.state);
        when(() => location.country).thenReturn(testLocation.country);
        when(() => location.countryCode).thenReturn(testLocation.countryCode);
        final weather = MockWeather();
        final int testWeatherCode = 77; //WeatherCondition.snowy
        final WeatherCondition testWeatherCondition = WeatherCondition.snowy;
        when(() => weather.temperature).thenReturn(testTemperature);
        when(() => weather.weatherCode).thenReturn(testWeatherCode);
        when(() => weatherApiClient.getLocation(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude')),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(testLocation.city);
        expect(
          actual,
          Weather(
            temperature: testTemperature,
            location: testLocation,
            condition: testWeatherCondition,
          ),
        );
      });

      test('returns correct weather on success (unknown)', () async {
        final location = MockLocation();
        when(() => location.latitude).thenReturn(latitude);
        when(() => location.longitude).thenReturn(longitude);
        when(() => location.city).thenReturn(testLocation.city);
        when(() => location.state).thenReturn(testLocation.state);
        when(() => location.country).thenReturn(testLocation.country);
        when(() => location.countryCode).thenReturn(testLocation.countryCode);
        final weather = MockWeather();
        final int testWeatherCode = -1; //WeatherCondition.unknown
        final WeatherCondition testWeatherCondition = WeatherCondition.unknown;
        when(() => weather.temperature).thenReturn(testTemperature);
        when(() => weather.weatherCode).thenReturn(testWeatherCode);
        when(() => weatherApiClient.getLocation(any())).thenAnswer(
          (_) async => location,
        );
        when(
          () => weatherApiClient.getWeather(
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude')),
        ).thenAnswer((_) async => weather);
        final actual = await weatherRepository.getWeather(testLocation.city);
        expect(
          actual,
          Weather(
            temperature: testTemperature,
            location: testLocation,
            condition: testWeatherCondition,
          ),
        );
      });
    });
  });
}
