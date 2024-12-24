// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Weather _$WeatherFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Weather',
      json,
      ($checkedConvert) {
        final val = Weather(
          condition: $checkedConvert(
              'condition', (v) => $enumDecode(_$WeatherConditionEnumMap, v)),
          location: $checkedConvert('location',
              (v) => weather_repo.Location.fromJson(v as Map<String, dynamic>)),
          temperature: $checkedConvert('temperature',
              (v) => Temperature.fromJson(v as Map<String, dynamic>)),
          lastUpdated: $checkedConvert(
              'last_updated', (v) => DateTime.parse(v as String)),
        );
        return val;
      },
      fieldKeyMap: const {'lastUpdated': 'last_updated'},
    );

Map<String, dynamic> _$WeatherToJson(Weather instance) => <String, dynamic>{
      'temperature': instance.temperature.toJson(),
      'condition': _$WeatherConditionEnumMap[instance.condition]!,
      'location': instance.location.toJson(),
      'last_updated': instance.lastUpdated.toIso8601String(),
    };

const _$WeatherConditionEnumMap = {
  weather_repo.WeatherCondition.clear: 'clear',
  weather_repo.WeatherCondition.rainy: 'rainy',
  weather_repo.WeatherCondition.cloudy: 'cloudy',
  weather_repo.WeatherCondition.snowy: 'snowy',
  weather_repo.WeatherCondition.unknown: 'unknown',
};
