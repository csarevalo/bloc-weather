import 'package:open_meteo_api/open_meteo_api.dart' as wapi;

import 'models/models.dart';

class WeatherRepository {
  WeatherRepository({
    wapi.OpenMeteoApiClient? weatherApiClient,
  }) : _weatherApiClient = weatherApiClient ?? wapi.OpenMeteoApiClient();

  final wapi.OpenMeteoApiClient _weatherApiClient;

  Future<Weather> getWeather(String location) async {
    final place = await _weatherApiClient.getLocation(location);
    final weather = await _weatherApiClient.getWeather(
      latitude: place.latitude,
      longitude: place.longitude,
    );
    return Weather(
      location: Location(
        city: place.city,
        state: place.state,
        country: place.country,
        countryCode: place.countryCode,
      ),
      temperature: weather.temperature,
      condition: weather.weatherCode.toCondition,
    );
  }
}

extension on int {
  WeatherCondition get toCondition {
    switch (this) {
      case 0:
        return WeatherCondition.clear;
      case 1:
      case 2:
      case 3:
      case 45:
      case 48:
        return WeatherCondition.cloudy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
      case 95:
      case 96:
      case 99:
        return WeatherCondition.rainy;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return WeatherCondition.snowy;
      default:
        return WeatherCondition.unknown;
    }
  }
}
