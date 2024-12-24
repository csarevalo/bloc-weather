// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Location',
      json,
      ($checkedConvert) {
        final val = Location(
          country: $checkedConvert('country', (v) => v as String),
          countryCode: $checkedConvert('country_code', (v) => v as String),
          state: $checkedConvert('state', (v) => v as String),
          city: $checkedConvert('city', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {'countryCode': 'country_code'},
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'country': instance.country,
      'country_code': instance.countryCode,
      'state': instance.state,
      'city': instance.city,
    };
