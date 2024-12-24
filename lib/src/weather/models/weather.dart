import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weather_repository/weather_repository.dart' as weather_repo;

import 'temperature.dart';

part 'weather.g.dart';

@JsonSerializable()
class Weather extends Equatable {
  final Temperature temperature;
  final weather_repo.WeatherCondition condition;
  final weather_repo.Location location;
  final DateTime lastUpdated;

  const Weather({
    required this.condition,
    required this.location,
    required this.temperature,
    required this.lastUpdated,
  });

  /// Creates [Weather] object from [WeatherRepository]'s definition of Weather.
  /// Delivers the weather temperature in Celcius.
  factory Weather.fromRepository(weather_repo.Weather weather) {
    return Weather(
      temperature: Temperature(value: weather.temperature),
      condition: weather.condition,
      location: weather.location,
      lastUpdated: DateTime.now(),
    );
  }
  static final empty = Weather(
    condition: weather_repo.WeatherCondition.unknown,
    temperature: const Temperature(value: 0),
    location: weather_repo.Location(
        country: '--', countryCode: '--', state: '--', city: '--'),
    lastUpdated: DateTime(0),
  );

  Weather copyWith({
    Temperature? temperature,
    weather_repo.WeatherCondition? condition,
    weather_repo.Location? location,
    DateTime? lastUpdated,
  }) {
    return Weather(
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory Weather.fromJson(Map<String, dynamic> json) =>
      _$WeatherFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  @override
  List<Object?> get props => [temperature, condition, location, lastUpdated];
}
