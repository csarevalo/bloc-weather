import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_weather/src/weather/cubit/weather_cubit.dart';
import 'package:bloc_weather/src/weather/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart'
    as weather_repository;

class MockWeatherRepository extends Mock
    implements weather_repository.WeatherRepository {}

class MockWeather extends Mock implements weather_repository.Weather {}

class MockStorage extends Mock implements Storage {}

final weatherLocation = weather_repository.Location(
  country: 'United States',
  countryCode: 'US',
  state: 'California',
  city: 'Los Angeles',
);
const weatherCondition = weather_repository.WeatherCondition.rainy;
const weatherTemperature = 9.8;

main() {
  group('WeatherCubit', () {
    late Storage hydratedStorage;
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      hydratedStorage = MockStorage();
      when(
        () => hydratedStorage.write(any(), any<dynamic>()),
      ).thenAnswer((_) async {});
      HydratedBloc.storage = hydratedStorage;
    });

    late weather_repository.Weather weather;
    late weather_repository.WeatherRepository weatherRepository;
    late WeatherCubit weatherCubit;
    setUp(() {
      weather = MockWeather();
      when(() => weather.condition).thenReturn(weatherCondition);
      when(() => weather.temperature).thenReturn(weatherTemperature);
      when(() => weather.location).thenReturn(weatherLocation);

      weatherRepository = MockWeatherRepository();
      when(() => weatherRepository.getWeather(any()))
          .thenAnswer((_) async => weather);

      weatherCubit = WeatherCubit(weatherRepository);
    });

    test('initial state is correct', () {
      expect(WeatherCubit(weatherRepository).state, WeatherState());
    });

    group('toJson/fromJson', () {
      test('work properly', () {
        expect(
          weatherCubit.fromJson(weatherCubit.toJson(weatherCubit.state)),
          weatherCubit.state,
        );
      });
    });

    group('.fetchWeather()', () {
      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is null',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(null),
        expect: () => <WeatherState>[],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits nothing when city is empty',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(''),
        expect: () => <WeatherState>[],
      );

      blocTest(
        'calls fetchWeather with correct city',
        build: () => weatherCubit,
        act: (cubit) => cubit.fetchWeather(weatherLocation.city),
        verify: (_) => verify(
          () => weatherRepository.getWeather(weatherLocation.city),
        ).called(1),
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, failure] when getWeather throws exception',
        build: () => weatherCubit,
        setUp: () => when(() => weatherRepository.getWeather(any()))
            .thenThrow(Exception('oops')),
        act: (cubit) => cubit.fetchWeather(weatherLocation.city),
        expect: () => <WeatherState>[
          WeatherState(status: WeatherStatus.loading),
          WeatherState(status: WeatherStatus.failure),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, success] when getWeather returns (Celsius)',
        build: () => weatherCubit,
        setUp: () => when(() => weatherRepository.getWeather(any()))
            .thenAnswer((_) async => weather),
        act: (cubit) => cubit.fetchWeather(weatherLocation.city),
        expect: () => <dynamic>[
          WeatherState(status: WeatherStatus.loading),
          isA<WeatherState>()
              .having((ws) => ws.status, 'status', WeatherStatus.success)
              .having((ws) => ws.temperatureUnits, 'temperature units',
                  TemperatureUnits.celsius)
              .having(
                (ws) => ws.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.condition, 'weather condition',
                        weatherCondition)
                    .having((w) => w.location, 'location', weatherLocation)
                    .having((w) => w.temperature, 'temperature',
                        Temperature(value: weather.temperature))
                    .having((w) => w.lastUpdated, 'last update', isNotNull),
              ),
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits [loading, success] when getWeather returns (Fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(temperatureUnits: TemperatureUnits.fahrenheit),
        setUp: () => when(() => weatherRepository.getWeather(any()))
            .thenAnswer((_) async => weather),
        act: (cubit) => cubit.fetchWeather(weatherLocation.city),
        expect: () => <dynamic>[
          WeatherState(
            status: WeatherStatus.loading,
            temperatureUnits: TemperatureUnits.fahrenheit,
          ),
          isA<WeatherState>()
              .having((ws) => ws.status, 'status', WeatherStatus.success)
              .having((ws) => ws.temperatureUnits, 'temperature units',
                  TemperatureUnits.fahrenheit)
              .having(
                (ws) => ws.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.condition, 'weather condition',
                        weatherCondition)
                    .having((w) => w.location, 'location', weatherLocation)
                    .having(
                      (w) => w.temperature,
                      'temperature',
                      Temperature(
                          value: weather.temperature.toFahrenheit(),
                          units: TemperatureUnits.fahrenheit),
                    )
                    .having((w) => w.lastUpdated, 'last update', isNotNull),
              ),
        ],
      );
    });

    group('.refreshWeather()', () {
      blocTest(
        'emits nothing when status is not success',
        build: () => weatherCubit,
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) => verifyNever(() => weatherRepository.getWeather(any())),
      );

      blocTest(
        'emits nothing when previous weather is null (location is null)',
        build: () => weatherCubit,
        seed: () => WeatherState(status: WeatherStatus.success),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
        verify: (_) => verifyNever(() => weatherRepository.getWeather(any())),
      );

      blocTest(
        'invokes getWeather with correct location',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather.fromRepository(weather),
        ),
        act: (cubit) => cubit.refreshWeather(),
        verify: (_) => verify(
          () => weatherRepository.getWeather(weatherLocation.city),
        ),
      );

      blocTest(
        'emits nothing when an exception is thrown',
        build: () => weatherCubit,
        setUp: () => when(() => weatherRepository.getWeather(any()))
            .thenThrow(Exception('oops')),
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather.fromRepository(weather),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <WeatherState>[],
      );

      blocTest(
        'emits updated weather (celsius)',
        setUp: () => when(() => weatherRepository.getWeather(any()))
            .thenAnswer((_) async => weather),
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          weather: Weather.fromRepository(weather).copyWith(
            temperature: const Temperature(value: -11),
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <dynamic>[
          isA<WeatherState>()
              .having((ws) => ws.status, 'status', WeatherStatus.success)
              .having(
                  (ws) => ws.weather,
                  'weather',
                  isA<Weather>()
                      .having((w) => w.lastUpdated, 'last updated', isNotNull)
                      .having((w) => w.condition, 'weather condition',
                          weatherCondition)
                      .having((w) => w.location, 'weather location',
                          weatherLocation)
                      .having((w) => w.temperature, 'weather temperature',
                          Temperature(value: weather.temperature)))
        ],
      );

      blocTest(
        'emits updated weather (fahrenheit)',
        setUp: () => when(() => weatherRepository.getWeather(any()))
            .thenAnswer((_) async => weather),
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          temperatureUnits: TemperatureUnits.fahrenheit,
          weather: Weather.fromRepository(weather).copyWith(
            temperature: const Temperature(value: -11),
          ),
        ),
        act: (cubit) => cubit.refreshWeather(),
        expect: () => <dynamic>[
          isA<WeatherState>()
              .having((ws) => ws.status, 'status', WeatherStatus.success)
              .having((ws) => ws.temperatureUnits, 'temperature units',
                  TemperatureUnits.fahrenheit)
              .having(
                (ws) => ws.weather,
                'weather',
                isA<Weather>()
                    .having((w) => w.lastUpdated, 'last updated', isNotNull)
                    .having((w) => w.condition, 'weather condition',
                        weatherCondition)
                    .having(
                        (w) => w.location, 'weather location', weatherLocation)
                    .having(
                      (w) => w.temperature,
                      'weather temperature',
                      Temperature(
                          value: weather.temperature.toFahrenheit(),
                          units: TemperatureUnits.fahrenheit),
                    ),
              )
        ],
      );
    });

    group('.toggleUnits()', () {
      blocTest(
        'emits updated units on not success',
        build: () => weatherCubit,
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(temperatureUnits: TemperatureUnits.fahrenheit)
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated units and temperature when status is success (fahrenheit)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          temperatureUnits: TemperatureUnits.celsius,
          weather: Weather.fromRepository(weather)
              .copyWith(lastUpdated: DateTime(2024)),
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.success,
            temperatureUnits: TemperatureUnits.fahrenheit,
            weather: Weather.fromRepository(weather).copyWith(
                temperature: Temperature(
                  value: weather.temperature.toFahrenheit(),
                  units: TemperatureUnits.fahrenheit,
                ),
                lastUpdated: DateTime(2024)),
          )
        ],
      );

      blocTest<WeatherCubit, WeatherState>(
        'emits updated units and temperature when status is success (celsius)',
        build: () => weatherCubit,
        seed: () => WeatherState(
          status: WeatherStatus.success,
          temperatureUnits: TemperatureUnits.fahrenheit,
          weather: Weather.fromRepository(weather).copyWith(
            lastUpdated: DateTime(2024),
            temperature: Temperature(
                value: weather.temperature.toFahrenheit(),
                units: TemperatureUnits.fahrenheit),
          ),
        ),
        act: (cubit) => cubit.toggleUnits(),
        expect: () => <WeatherState>[
          WeatherState(
            status: WeatherStatus.success,
            temperatureUnits: TemperatureUnits.celsius,
            weather: Weather.fromRepository(weather).copyWith(
                temperature: Temperature(
                  value: weather.temperature,
                  units: TemperatureUnits.celsius,
                ),
                lastUpdated: DateTime(2024)),
          )
        ],
      );
    });
  });
}

extension on double {
  double toFahrenheit() => (this * 9 / 5) + 32;
  double toCelsius() => (this - 32) * 5 / 9;
}
