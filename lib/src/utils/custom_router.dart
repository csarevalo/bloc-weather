import 'package:flutter/material.dart';

import '../search/view/search_screen.dart';
import '../settings/view/settings_screen.dart';
import '../weather/view/weather_screen.dart';

class CustomRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) {
        switch (settings.name) {
          case WeatherScreen.route:
            return const WeatherScreen();
          case SearchScreen.route:
            return const SearchScreen();
          case SettingsScreen.route:
            return const SettingsScreen();
          default:
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: Text('404: Missing Route'),
              ),
            );
        }
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 1);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: kThemeAnimationDuration, // 300 milliseconds
      reverseTransitionDuration: kThemeAnimationDuration, // 300 milliseconds
    );
  }
}
