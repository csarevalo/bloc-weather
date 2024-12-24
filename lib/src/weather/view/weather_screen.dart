import 'package:bloc_weather/src/search/search.dart';
import 'package:bloc_weather/src/settings/settings.dart';
import 'package:bloc_weather/src/utils/weather_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../weather.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({
    super.key,
  });

  static const String route = 'weather';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Weather'),
        actions: [
          IconButton(
            key: const ValueKey('weatherScreen_settingsButton'),
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.route),
            icon: const Icon(Icons.settings),
          ),
          const SizedBox(width: 2)
        ],
      ),
      body: Stack(
        children: [
          const WeatherBackground(),
          BlocBuilder<WeatherCubit, WeatherState>(
            builder: (context, state) {
              return switch (state.status) {
                WeatherStatus.initial => const WeatherEmpty(),
                WeatherStatus.loading => const WeatherLoading(),
                WeatherStatus.failure => const WeatherError(),
                WeatherStatus.success => WeatherPopulated(
                    weather: state.weather,
                    units: state.weather.temperature.units,
                    onRefresh: () async {
                      return context.read<WeatherCubit>().refreshWeather();
                    },
                  ),
              };
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('weatherScreen_searchButton'),
        onPressed: () async {
          final city = await Navigator.pushNamed(context, SearchScreen.route);
          if (city == null || city.runtimeType != String) return;
          if ((city as String).isEmpty) return;
          if (!context.mounted) return;
          context.read<WeatherCubit>().fetchWeather(city);
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
