

import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class LocationSearchDelegate extends SearchDelegate {
  String currentTimezone = '';
  List<String> searchResults = [];
  List<String> excludeList = [];
  LocationSearchDelegate (String tz, List<String> zones) {
    currentTimezone = tz;
    excludeList = zones;
    searchResults = timeZoneDatabase.locations.keys.toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        if (query.isEmpty) {
          close(context, null);
        } else {
          query = '';
        }
      },
    ),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => Center(
    child: Text(
      query,
      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
    ),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> suggestions = searchResults
      .where((searchResult) => !excludeList.contains(searchResult) && searchResult.toLowerCase().contains(query.toLowerCase()))
      .toList();
    debugPrint('${suggestions.length}');

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        if (suggestions.isEmpty) {
          return const ListTile(
            title: Text('No results'),
          );
        }
        final suggestion = suggestions[index];

        return ListTile(
          title: Text(suggestion),
          onTap: () {
            Navigator.pop(context, suggestion);
          },
        );
      },
    );
  }

}
