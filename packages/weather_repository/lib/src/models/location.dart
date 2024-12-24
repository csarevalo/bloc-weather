import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location.g.dart';

@JsonSerializable()
class Location extends Equatable {
  final String country;
  final String countryCode;
  final String state;
  final String city;

  Location({
    required this.country,
    required this.countryCode,
    required this.state,
    required this.city,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

  @override
  List<Object?> get props => [country, countryCode, state, city];
}
