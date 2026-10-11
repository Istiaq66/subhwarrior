import 'package:flutter/material.dart';
import 'package:subh_warrior/core/l10n/app_localizations.dart';
import 'package:subh_warrior/core/theme/app_snack_bars.dart';
import 'package:subh_warrior/features/prayer_times/data/location_data_source.dart';
import 'package:subh_warrior/helpers/location_access.dart';

import '../data/city_catalog.dart';
import '../domain/city.dart';
import 'city_picker.dart';

/// Location field shared by onboarding and Settings: pick a city from the
/// bundled list, or use the device position, named after its nearest city.
/// Both resolve offline once location access is granted.
class LocationSelector extends StatefulWidget {
  const LocationSelector({
    super.key,
    required this.label,
    required this.onSelected,
  });

  /// The current location's label; empty when none is set.
  final String label;
  final ValueChanged<City> onSelected;

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  bool _locating = false;

  Future<void> _pick() async {
    final city = await showCityPicker(context);
    if (city != null) widget.onSelected(city);
  }

  Future<void> _useDevice() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _locating = true);
    try {
      final access = await requestLocationAccess();
      if (!mounted) return;
      if (access != LocationAccess.granted) {
        showLocationAccessSnack(context, access);
        return;
      }
      final fix = await LocationDataSource.deviceFix();
      final catalog = await CityCatalog.load();
      widget.onSelected(catalog
          .nearest(fix.latitude, fix.longitude)
          .at(fix.latitude, fix.longitude));
    } catch (_) {
      if (!mounted) return;
      showLocationSnack(context, l10n.locationDetectFailed,
          kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: _pick,
          child: InputDecorator(
            isEmpty: widget.label.isEmpty,
            decoration: InputDecoration(
              labelText: l10n.onboardingLocationFieldLabel,
              hintText: l10n.locationChooseCity,
              prefixIcon: const Icon(Icons.map),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            child: Text(widget.label),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _locating ? null : _useDevice,
          icon: _locating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
          label: Text(_locating
              ? l10n.onboardingGettingLocation
              : l10n.onboardingUseCurrentLocation),
        ),
      ],
    );
  }
}
