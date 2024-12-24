import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'temperature.g.dart';

@JsonSerializable()
class Temperature extends Equatable {
  final double value;
  final TemperatureUnits units;

  const Temperature({
    required this.value,
    this.units = TemperatureUnits.celsius,
  });

  Temperature copyWith({
    double? value,
    TemperatureUnits? units,
  }) {
    return Temperature(
      value: value ?? this.value,
      units: units ?? this.units,
    );
  }

  factory Temperature.fromJson(Map<String, dynamic> json) =>
      _$TemperatureFromJson(json);

  Map<String, dynamic> toJson() => _$TemperatureToJson(this);

  @override
  List<Object?> get props => [value, units];
}

enum TemperatureUnits { fahrenheit, celsius }

extension TemperatureUnitsX on TemperatureUnits {
  bool get isFahrenheit => this == TemperatureUnits.fahrenheit;
  bool get isCelsius => this == TemperatureUnits.celsius;
}
