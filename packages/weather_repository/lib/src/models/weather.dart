import 'package:equatable/equatable.dart';

import 'location.dart';

class Weather extends Equatable {
  final Location location;
  final double temperature;
  final WeatherCondition condition;

  Weather({
    required this.location,
    required this.temperature,
    required this.condition,
  });

  @override
  List<Object?> get props => [location, temperature, condition];
}

enum WeatherCondition {
  clear,
  rainy,
  cloudy,
  snowy,
  unknown,
}
