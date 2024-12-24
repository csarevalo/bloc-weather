import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models/models.dart';

/// Dart API Client which wraps the [Open Meteo API](https://open-meteo.com).
class OpenMeteoApiClient {
  OpenMeteoApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _baseUrlWeather = 'api.open-meteo.com';
  static const _baseUrlGeocoding = 'geocoding-api.open-meteo.com';

  final http.Client _httpClient;

  /// Get the [Weather] of a `location` using latitude and longitude.
  Future<Weather> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final weatherRequest = Uri.https(_baseUrlWeather, '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current_weather': true.toString(),
    });
    final weatherResponse = await _httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final weatherJson =
        json.decode(weatherResponse.body) as Map<String, dynamic>;

    if (!weatherJson.containsKey('current_weather')) {
      throw WeatherNotFoundFailure();
    }

    return Weather.fromJson(weatherJson);
  }

  /// Get the [Location] of a `city` from [OpenMeteoApiClient] by looking up its name.
  Future<Location> getLocation(String cityName) async {
    final locationRequest = Uri.https(
      _baseUrlGeocoding,
      '/v1/search',
      {'name': cityName, 'count': 1.toString()},
    );
    final locationResponse = await _httpClient.get(locationRequest);

    if (locationResponse.statusCode != 200) {
      throw LocationRequestFailure();
    }

    final locationJson =
        json.decode(locationResponse.body) as Map<String, dynamic>;

    if (!locationJson.containsKey('results')) {
      throw LocationNotFoundFailure();
    }
    final results = locationJson['results'] as List;

    if (results.isEmpty) throw LocationNotFoundFailure();

    return Location.fromJson(locationJson);
  }
}

/// Exception thrown when locationSearch fails.
class LocationRequestFailure implements Exception {}

/// Exception thrown when the provided location is not found.
class LocationNotFoundFailure implements Exception {}

/// Exception thrown when getWeather fails.
class WeatherRequestFailure implements Exception {}

/// Exception thrown when weather for provided location is not found.
class WeatherNotFoundFailure implements Exception {}
