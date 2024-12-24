# Bloc Weather
**Check out the weather near you, or look up how other places are doing!**

Find out with ease using **[Bloc Weather](https://csarevalo.github.io/bloc-weather)**.

See a pleasant depiction of the weather data returned by [Open Meteo API](https://open-meteo.com/).

Built with flutter using a hydrated bloc.

## Purpose
Learn to develop flutter apps using BLoC to separate presentation from business logic and gauge its benefits over Provider.
* Updated UI based on part of bloc state with context.select<SubjectBloc, SelectedOutput>(..).
* Implemented a Hydrated Bloc to manage and persist state.
* Used Equatable to prevent unnecessary rebuilds.
* Built app using BlocListener, RepositoryProvider, and BlocProvider.

## Acknowledgements
This project was based on "Flutter Weather," a tutorial application available on the [Bloc Library](https://bloclibrary.dev/tutorials/flutter-weather).
