import 'package:flutter/material.dart';
import '/managers/location_manager.dart';

class LocationRefreshButton extends StatefulWidget {
  const LocationRefreshButton({super.key});

  @override
  State<LocationRefreshButton> createState() => _LocationRefreshButtonState();
}

class _LocationRefreshButtonState extends State<LocationRefreshButton> {
  bool _isRefreshing = false;

  Future<void> _onRefreshTap() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await LocationManager().refreshLocation();
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocationManager(),
      builder: (context, _) {
        final buildingName = LocationManager().currentBuildingName ?? '동국대 바깥';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _onRefreshTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_pin, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      buildingName,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: IconTheme.of(context).color),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isRefreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
