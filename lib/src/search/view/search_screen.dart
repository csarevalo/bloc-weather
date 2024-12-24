import 'package:bloc_weather/src/utils/weather_background.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
  });

  static const String route = 'search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController controller = TextEditingController();
  String get searchText => controller.text;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Find Your Weather'),
      ),
      body: Stack(
        children: [
          const WeatherBackground(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: _SearchBar(
                  key: const ValueKey('searchScreen_searchBar'),
                  autofocus: true,
                  controller: controller,
                  onSearch: () {
                    // Search bar internally ensures this is only executed when city
                    // is not empty
                    Navigator.pop(context, searchText); //return city on Pop
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final void Function()? onSearch;
  final TextEditingController controller;
  final bool autofocus;

  const _SearchBar({
    super.key,
    this.autofocus = false,
    required this.controller,
    this.onSearch,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late bool isEmpty; //remember if there was text
  bool isInitial = true;

  @override
  void initState() {
    super.initState();
    isEmpty = false; //always start as false to not show error text initially
    // isEmpty = widget.controller.text.isEmpty;
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 300,
        child: TextField(
          key: const ValueKey('searchScreen_searchBar_textfield'),
          controller: widget.controller,
          onEditingComplete:
              widget.controller.text.isEmpty ? null : widget.onSearch,
          onChanged: (String value) {
            if (value.isEmpty != isEmpty) {
              setState(() {
                isEmpty = value.isEmpty;
              });
            }
            if (isInitial) {
              // Should only be called once
              setState(() {
                isEmpty = value.isEmpty;
                isInitial = false;
              });
            }
          },
          autofocus: widget.autofocus,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: 'Look up a city',
            // labelText: 'City',
            // floatingLabelBehavior: FloatingLabelBehavior.always,
            errorText: isEmpty ? 'City name cannot be empty' : null,
            alignLabelWithHint: true,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: IconButton(
                key: const ValueKey('searchScreen_searchBar_submitButton'),
                iconSize: 20,
                onPressed:
                    widget.controller.text.isEmpty ? null : widget.onSearch,
                icon: const Icon(Icons.send),
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.secondaryContainer,
            contentPadding: const EdgeInsets.fromLTRB(18.0, 8.0, 16.0, 8.0),
            border: const OutlineInputBorder(),
          ),
        ),
      ),
    );
  }
}
