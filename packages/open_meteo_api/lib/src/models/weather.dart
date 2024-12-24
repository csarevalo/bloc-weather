class Weather {
  final double temperature;
  final String units;
  final int weatherCode;
  final DateTime lastUpdated;
  final String timezone;

  Weather({
    required this.temperature,
    required this.units,
    required this.weatherCode,
    required this.lastUpdated,
    required this.timezone,
  });

  Weather.fromJson(Map<String, dynamic> json)
      : temperature = json['current_weather']['temperature'] as double,
        units = json['current_weather_units']['temperature'] as String,
        weatherCode = json['current_weather']['weathercode'] as int,
        lastUpdated = DateTime.parse(
          json['current_weather']['time'] as String,
        ),
        timezone = json['timezone'];
}
