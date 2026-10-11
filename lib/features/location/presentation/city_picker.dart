import 'package:flutter/material.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';

import '../data/city_catalog.dart';
import '../domain/city.dart';

/// Full-screen, searchable list of the bundled cities. Resolves to the chosen
/// city, or null when dismissed.
Future<City?> showCityPicker(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const _CityPickerPage(),
    ));

class _CityPickerPage extends StatefulWidget {
  const _CityPickerPage();

  @override
  State<_CityPickerPage> createState() => _CityPickerPageState();
}

class _CityPickerPageState extends State<_CityPickerPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.locationPickerTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: l10n.locationSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<CityCatalog>(
              future: CityCatalog.load(),
              builder: (context, snapshot) {
                final catalog = snapshot.data;
                if (catalog == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final cities = catalog.search(_query);
                if (cities.isEmpty) {
                  return Center(child: Text(l10n.locationNoMatches));
                }
                return ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context, i) {
                    final city = cities[i];
                    return ListTile(
                      title: Text(city.name),
                      subtitle: Text(city.countryName),
                      onTap: () => Navigator.of(context).pop(city),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.all(8),
            child: Text(
              'City data: GeoNames.org (CC BY 4.0)',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
