import 'package:bloc_weather/src/utils/weather_background.dart';
import 'package:bloc_weather/src/weather/weather.dart'
    show TemperatureUnitsX, WeatherCubit, WeatherState;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });

  static const String route = 'settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Settings'),
      ),
      body: Stack(
        children: [
          const WeatherBackground(),
          ListView(
            children: <Widget>[
              BlocBuilder<WeatherCubit, WeatherState>(
                buildWhen: (previous, current) =>
                    previous.temperatureUnits != current.temperatureUnits,
                builder: (context, state) {
                  return ListTile(
                    title: const Text('Temperature Units'),
                    isThreeLine: true,
                    subtitle: const Text(
                      'Use metric measurements for temperature units.',
                    ),
                    trailing: Switch(
                      value: state.temperatureUnits.isCelsius,
                      onChanged: (_) =>
                          context.read<WeatherCubit>().toggleUnits(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
