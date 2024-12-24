import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' as wrepo;

import '../models/models.dart';

part 'weather_cubit.g.dart';
part 'weather_state.dart';

class WeatherCubit extends HydratedCubit<WeatherState> {
  WeatherCubit(this._weatherRepository) : super(WeatherState());

  final wrepo.WeatherRepository _weatherRepository;

  /// Try to fetch weather for a given `city` from [WeatherRepository],
  /// and update state.
  Future<void> fetchWeather(String? city) async {
    if (city == null || city.isEmpty) return;
    emit(state.copyWith(status: WeatherStatus.loading));
    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(city),
      );
      final units = state.temperatureUnits;
      final temperature = weather.temperature.copyWith(
        units: units,
        value: units == weather.temperature.units
            ? weather.temperature.value
            : units.isCelsius
                ? weather.temperature.value.toCelcius()
                : weather.temperature.value.toFahrenheit(),
      );
      emit(state.copyWith(
        status: WeatherStatus.success,
        weather: weather.copyWith(temperature: temperature),
      ));
    } on Exception {
      emit(state.copyWith(status: WeatherStatus.failure));
    }
  }

  Future<void> refreshWeather() async {
    if (!state.status.isSuccess) return;
    if (state.weather == Weather.empty) return;
    if (state.weather.location.city.isEmpty) return;
    try {
      final weather = Weather.fromRepository(
        await _weatherRepository.getWeather(state.weather.location.city),
      );
      final units = state.temperatureUnits;
      final temperature = weather.temperature.copyWith(
        units: units,
        value: units == weather.temperature.units
            ? weather.temperature.value
            : units.isCelsius
                ? weather.temperature.value.toCelcius()
                : weather.temperature.value.toFahrenheit(),
      );
      emit(state.copyWith(
        status: WeatherStatus.success,
        weather: weather.copyWith(temperature: temperature),
      ));
    } on Exception {
      emit(state); //don't change anything
    }
  }

  Future<void> toggleUnits() async {
    final units = state.temperatureUnits.isCelsius
        ? TemperatureUnits.fahrenheit
        : TemperatureUnits.celsius;

    if (!state.status.isSuccess) {
      emit(state.copyWith(temperatureUnits: units));
      return;
    }
    final weather = state.weather;
    final temperature = weather.temperature.copyWith(
      units: units,
      value: units == weather.temperature.units
          ? weather.temperature.value
          : units.isCelsius
              ? weather.temperature.value.toCelcius()
              : weather.temperature.value.toFahrenheit(),
    );
    emit(state.copyWith(
      temperatureUnits: units,
      weather: weather.copyWith(temperature: temperature),
    ));
  }

  @override
  WeatherState fromJson(Map<String, dynamic> json) =>
      WeatherState.fromJson(json);

  @override
  Map<String, dynamic> toJson(WeatherState state) => state.toJson();
}

extension on double {
  double toFahrenheit() => this * (9 / 5) + 32;
  double toCelcius() => (this - 32) * (5 / 9);
}
