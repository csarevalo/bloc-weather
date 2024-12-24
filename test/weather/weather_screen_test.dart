import 'package:bloc_test/bloc_test.dart';
import 'package:bloc_weather/src/search/view/search_screen.dart';
import 'package:bloc_weather/src/settings/view/settings_screen.dart';
import 'package:bloc_weather/src/utils/custom_router.dart';
import 'package:bloc_weather/src/weather/weather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart'
    hide Weather, Location;

class MockWeatherRepository extends Mock implements WeatherRepository {}

class MockStorage extends Mock implements Storage {}

class MockWeatherCubit extends MockCubit<WeatherState>
    implements WeatherCubit {}

void main() {
  group('WeatherScreen', () {
    late Storage hydratedStorage;
    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      hydratedStorage = MockStorage();
      when(
        () => hydratedStorage.write(any(), any<dynamic>()),
      ).thenAnswer((_) async {});
      HydratedBloc.storage = hydratedStorage;
    });

    final weatherLocation = Location(
      country: 'United States',
      countryCode: 'US',
      state: 'California',
      city: 'Los Angeles',
    );
    const weatherCondition = WeatherCondition.rainy;
    const weatherTemperature = Temperature(
      value: 25,
      units: TemperatureUnits.celsius,
    );
    final weather = Weather(
      condition: weatherCondition,
      location: weatherLocation,
      temperature: weatherTemperature,
      lastUpdated: DateTime(2024),
    );

    late WeatherCubit weatherCubit;
    setUp(() {
      weatherCubit = MockWeatherCubit();
    });

    testWidgets('renders WeatherEmpty for WeatherStatus.initial',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(home: WeatherScreen()),
      ));
      expect(find.byType(WeatherEmpty), findsOneWidget);
    });

    testWidgets('renders WeatherLoading for WeatherStatus.loading',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(status: WeatherStatus.loading),
      );
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(home: WeatherScreen()),
      ));
      expect(find.byType(WeatherLoading), findsOneWidget);
    });

    testWidgets('renders WeatherError for WeatherStatus.failure',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(status: WeatherStatus.failure),
      );
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(home: WeatherScreen()),
      ));
      expect(find.byType(WeatherError), findsOneWidget);
    });

    testWidgets('renders WeatherPopulated for WeatherStatus.success',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
          temperatureUnits: TemperatureUnits.celsius,
        ),
      );
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(home: WeatherScreen()),
      ));
      expect(find.byType(WeatherPopulated), findsOneWidget);
    });

    testWidgets('state is cached', (tester) async {
      when<dynamic>(() => hydratedStorage.read('$WeatherCubit')).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
          temperatureUnits: TemperatureUnits.celsius,
        ).toJson(),
      );
      await tester.pumpWidget(BlocProvider.value(
        value: WeatherCubit(MockWeatherRepository()),
        child: const MaterialApp(home: WeatherScreen()),
      ));
      expect(find.byType(WeatherPopulated), findsOneWidget);
    });
    testWidgets('Navigate to SettingsScreen when settings IconButton is tapped',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(
          onGenerateRoute: CustomRouter.onGenerateRoute,
          home: WeatherScreen(),
        ),
      ));
      await tester.tap(
        // find.byType(IconButton),
        find.byKey(const ValueKey('weatherScreen_settingsButton')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets(
        'Navigate to SearchScreen when settings FloatingActionButton is tapped',
        (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(
          onGenerateRoute: CustomRouter.onGenerateRoute,
          home: WeatherScreen(),
        ),
      ));
      await tester.tap(
        // find.byType(FloatingActionButton),
        find.byKey(const ValueKey('weatherScreen_searchButton')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('triggers refreshWeather on pull to refresh', (tester) async {
      when(() => weatherCubit.state).thenReturn(
        WeatherState(
          status: WeatherStatus.success,
          weather: weather,
          temperatureUnits: TemperatureUnits.celsius,
        ),
      );
      when(() => weatherCubit.refreshWeather()).thenAnswer((_) async {});
      await tester.pumpWidget(
        BlocProvider.value(
          value: weatherCubit,
          child: const MaterialApp(home: WeatherScreen()),
        ),
      );
      await tester.fling(
        find.text(weather.location.city),
        const Offset(0, 500),
        1000,
      );
      await tester.pumpAndSettle();
      verify(() => weatherCubit.refreshWeather()).called(1);
    });

    testWidgets('triggers fetch on search pop', (tester) async {
      when(() => weatherCubit.state).thenReturn(WeatherState());
      when(() => weatherCubit.fetchWeather(any())).thenAnswer((_) async {});
      await tester.pumpWidget(BlocProvider.value(
        value: weatherCubit,
        child: const MaterialApp(
          onGenerateRoute: CustomRouter.onGenerateRoute,
          home: WeatherScreen(),
        ),
      ));
      await tester.tap(
        find.byKey(const ValueKey('weatherScreen_searchButton')),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        // find.byType(TextField),
        find.byKey(const ValueKey('searchScreen_searchBar_textfield')),
        weather.location.city,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('searchScreen_searchBar_submitButton')),
      );
      await tester.pumpAndSettle();
      verify(() => weatherCubit.fetchWeather(weather.location.city)).called(1);
    });
  });
}
