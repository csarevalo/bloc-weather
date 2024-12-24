import 'package:flutter/material.dart';

import '../models/models.dart';

class WeatherPopulated extends StatelessWidget {
  const WeatherPopulated({
    required this.weather,
    required this.units,
    required this.onRefresh,
    super.key,
  });

  final Weather weather;
  final TemperatureUnits units;
  final ValueGetter<Future<void>> onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: onRefresh,
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          clipBehavior: Clip.none,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(weather.location.formattedLocation),
              const SizedBox(height: 48),
              _WeatherIcon(condition: weather.condition),
              Text(
                weather.location.city,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w200,
                ),
              ),
              Text(
                weather.formattedTemperature(units),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '''Last Updated at ${TimeOfDay.fromDateTime(weather.lastUpdated).format(context)}''',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({required this.condition});

  static const _iconSize = 75.0;

  final WeatherCondition condition;

  @override
  Widget build(BuildContext context) {
    return Text(
      condition.toEmoji,
      style: const TextStyle(fontSize: _iconSize),
    );
  }
}

extension on WeatherCondition {
  String get toEmoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.snowy:
        return '🌨️';
      case WeatherCondition.unknown:
        return '❓';
    }
  }
}

extension on Location {
  String get formattedLocation {
    List<String> locations = [];
    if (city.isNotEmpty) locations.add(city);
    if (state.isNotEmpty) locations.add(state);
    if (country.isNotEmpty) locations.add(country);
    return locations.toSet().join(", ");
  }
}

extension on Weather {
  String formattedTemperature(TemperatureUnits units) {
    return '''${temperature.value.toStringAsPrecision(2)}°${units.isCelsius ? 'C' : 'F'}''';
  }
}
