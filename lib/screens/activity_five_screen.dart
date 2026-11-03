import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ActivityFiveScreen extends StatefulWidget {
  const ActivityFiveScreen({super.key});

  @override
  State<ActivityFiveScreen> createState() => _ActivityFiveScreenState();
}

class _ActivityFiveScreenState extends State<ActivityFiveScreen> {
  // ============================================================
  // MAP SETTINGS
  // ============================================================

  static const Color googleBlue = Color(0xFF4285F4);
  static const Color forestGreen = Color(0xFF075B48);

  static const double geofenceRadius = 100;

  static const CameraPosition initialCamera = CameraPosition(
    target: LatLng(8.6335, 126.0950),
    zoom: 15,
  );

  GoogleMapController? _mapController;

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;

  bool _hasPermission = false;
  bool _isLoading = true;
  bool _mapReady = false;

  String _statusMessage = 'Getting your location...';

  String? _activeGeofenceId;
  String? _selectedLocationId;

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];

  // ============================================================
  // FIVE CUSTOM LOCATIONS IN LIANGA
  // ============================================================

  final List<Map<String, dynamic>> _customLocations = [
    {
      'id': 'loc1',
      'name': 'Custom Tagarda Beach Resort 1',
      'description': 'First custom location in Lianga.',
      'lat': 8.622999,
      'lng': 126.095888,
    },
    {
      'id': 'loc2',
      'name': 'Custom foodpark 2',
      'description': 'Second custom location in Lianga.',
      'lat': 8.635226,
      'lng': 126.095151,
    },
    {
      'id': 'loc3',
      'name': 'Custom Bat-ao 3',
      'description': 'Third custom location in Lianga.',
      'lat': 8.633055,
      'lng': 126.094760,
    },
    {
      'id': 'loc4',
      'name': 'Custom Ole Beach Resto 4',
      'description':
          'Fourth custom location Near Big Times Beach Resort in Lianga.',
      'lat': 8.622403,
      'lng': 126.093972,
    },
    {
      'id': 'loc5',
      'name': 'Custom Lawis Beach  5',
      'description':
          'Fifth custom location Near Morzant Beach Resort in Lianga.',
      'lat': 8.640577,
      'lng': 126.095165,
    },
  ];

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    _searchResults = List.from(_customLocations);

    _initializeLocation();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _searchController.dispose();
    _mapController?.dispose();

    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _statusMessage = 'Please enable GPS location.';
            _isLoading = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _statusMessage = 'Location permission is required.';
            _isLoading = false;
          });
        }
        return;
      }

      _hasPermission = true;

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _statusMessage = 'GPS Connected';
      });

      _moveToCurrentLocation();

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((Position position) {
            if (!mounted) return;

            setState(() {
              _currentPosition = position;
            });

            _checkGeofences(position);
          });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _statusMessage = 'Unable to get GPS location.';
      });
    }
  }

  // ============================================================
  // HAVERSINE FORMULA
  // ============================================================

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;

    double toRadians(double degree) {
      return degree * math.pi / 180;
    }

    final double dLat = toRadians(lat2 - lat1);
    final double dLon = toRadians(lon2 - lon1);

    final double a =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRadians(lat1)) *
            math.cos(toRadians(lat2)) *
            math.pow(math.sin(dLon / 2), 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  // ============================================================
  // GEOFENCING
  // ============================================================

  void _checkGeofences(Position position) {
    String? detectedLocationId;
    Map<String, dynamic>? detectedLocation;

    for (final location in _customLocations) {
      final double distance = calculateDistance(
        position.latitude,
        position.longitude,
        location['lat'],
        location['lng'],
      );

      if (distance <= geofenceRadius) {
        detectedLocationId = location['id'];
        detectedLocation = location;
        break;
      }
    }

    if (detectedLocationId != _activeGeofenceId) {
      final String? previousId = _activeGeofenceId;

      setState(() {
        _activeGeofenceId = detectedLocationId;
      });

      if (previousId != null) {
        final previousLocation = _customLocations.firstWhere(
          (loc) => loc['id'] == previousId,
        );

        _showGeofenceAlert(
          'EXITED',
          previousLocation['name'],
          Colors.orange.shade800,
        );
      }

      if (detectedLocation != null) {
        _showGeofenceAlert(
          'ENTERED',
          detectedLocation['name'],
          Colors.green.shade800,
        );
      }
    }
  }

  void _showGeofenceAlert(String event, String locationName, Color color) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$event GEOFENCE: $locationName',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH LOCATION
  // ============================================================

  void _searchLocation(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _searchResults = List.from(_customLocations);
      } else {
        _searchResults = _customLocations.where((location) {
          return location['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              location['description'].toString().toLowerCase().contains(
                query.toLowerCase(),
              );
        }).toList();
      }
    });
  }

  void _selectLocation(Map<String, dynamic> location) {
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedLocationId = location['id'];
      _searchController.text = location['name'];
      _searchResults = [];
    });

    _goToLocation(location['lat'], location['lng']);
  }

  // ============================================================
  // CAMERA CONTROLS
  // ============================================================

  void _goToLocation(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, lng), zoom: 18),
      ),
    );
  }

  void _moveToCurrentLocation() {
    if (_currentPosition == null) return;

    _goToLocation(_currentPosition!.latitude, _currentPosition!.longitude);
  }

  // ============================================================
  // MAP MARKERS
  // ============================================================

  Set<Marker> _buildMarkers() {
    final Set<Marker> markers = {};

    for (final location in _customLocations) {
      markers.add(
        Marker(
          markerId: MarkerId(location['id']),
          position: LatLng(location['lat'], location['lng']),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _selectedLocationId == location['id']
                ? BitmapDescriptor.hueAzure
                : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: location['name'],
            snippet: location['description'],
          ),
          onTap: () {
            setState(() {
              _selectedLocationId = location['id'];
              _searchController.text = location['name'];
            });
          },
        ),
      );
    }

    return markers;
  }

  // ============================================================
  // GEOFENCE CIRCLE
  // ============================================================

  Set<Circle> _buildCircles() {
    final Set<Circle> circles = {};

    for (final location in _customLocations) {
      final bool isSelected = _selectedLocationId == location['id'];

      final bool isActive = _activeGeofenceId == location['id'];

      if (isSelected || isActive) {
        circles.add(
          Circle(
            circleId: CircleId(location['id']),
            center: LatLng(location['lat'], location['lng']),
            radius: geofenceRadius,
            fillColor: Colors.blue.withValues(alpha: 0.15),
            strokeColor: isActive ? Colors.green : googleBlue,
            strokeWidth: 2,
          ),
        );
      }
    }

    return circles;
  }

  // ============================================================
  // SELECTED LOCATION INFORMATION
  // ============================================================

  Map<String, dynamic>? get _selectedLocation {
    if (_selectedLocationId == null) return null;

    try {
      return _customLocations.firstWhere(
        (location) => location['id'] == _selectedLocationId,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // BUILD USER INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final selected = _selectedLocation;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ----------------------------------------------------
          // GOOGLE MAPS SATELLITE VIEW
          // ----------------------------------------------------
          GoogleMap(
            mapType: MapType.satellite,
            initialCameraPosition: initialCamera,
            markers: _buildMarkers(),
            circles: _buildCircles(),
            myLocationEnabled: _hasPermission,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            buildingsEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              _mapReady = true;

              if (_currentPosition != null) {
                _moveToCurrentLocation();
              }
            },
          ),

          // ----------------------------------------------------
          // TOP SEARCH BAR
          // ----------------------------------------------------
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchLocation,
                    decoration: InputDecoration(
                      hintText: 'Search Lianga locations',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF5F6368),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.mic_none),
                        onPressed: () {},
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),

                // SEARCH RESULTS
                if (_searchResults.isNotEmpty &&
                    _searchController.text.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final location = _searchResults[index];

                        return ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: googleBlue,
                          ),
                          title: Text(location['name']),
                          subtitle: Text(
                            location['description'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _selectLocation(location),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ----------------------------------------------------
          // QUICK CATEGORY BUTTONS
          // ----------------------------------------------------
          Positioned(
            top: MediaQuery.of(context).padding.top + 75,
            left: 15,
            right: 15,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickButton(Icons.explore, 'Explore', () {
                    _searchController.clear();
                    _searchLocation('');
                  }),
                  _quickButton(
                    Icons.home_outlined,
                    'My Location',
                    _moveToCurrentLocation,
                  ),
                  _quickButton(Icons.place_outlined, 'Custom Pins', () {
                    setState(() {
                      _searchController.clear();
                      _searchResults = List.from(_customLocations);
                    });
                  }),
                ],
              ),
            ),
          ),

          // ----------------------------------------------------
          // RIGHT SIDE MAP CONTROLS
          // ----------------------------------------------------
          Positioned(
            right: 15,
            bottom: selected == null ? 155 : 245,
            child: Column(
              children: [
                _mapControl(Icons.my_location, _moveToCurrentLocation),
                const SizedBox(height: 12),
                _mapControl(Icons.add, () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                }),
                const SizedBox(height: 8),
                _mapControl(Icons.remove, () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                }),
              ],
            ),
          ),

          // ----------------------------------------------------
          // GPS STATUS
          // ----------------------------------------------------
          Positioned(
            left: 15,
            right: 15,
            bottom: selected == null ? 120 : 210,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 5),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _activeGeofenceId != null
                        ? Icons.location_on
                        : Icons.gps_fixed,
                    color: _activeGeofenceId != null
                        ? Colors.green
                        : googleBlue,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _activeGeofenceId != null
                          ? 'INSIDE GEOFENCE: ${_customLocations.firstWhere((loc) => loc['id'] == _activeGeofenceId)['name']}'
                          : _statusMessage,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (_currentPosition != null)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),

          // ----------------------------------------------------
          // SELECTED LOCATION INFORMATION PANEL
          // ----------------------------------------------------
          if (selected != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: _locationInformation(selected),
            ),

          // ----------------------------------------------------
          // BOTTOM LOCATION LIST
          // ----------------------------------------------------
          if (selected == null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: SizedBox(
                height: 95,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _customLocations.length,
                  itemBuilder: (context, index) {
                    final location = _customLocations[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLocationId = location['id'];
                        });

                        _goToLocation(location['lat'], location['lng']);
                      },
                      child: Container(
                        width: 185,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              location['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Lianga, Surigao del Sur',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK BUTTON WIDGET
  // ============================================================

  Widget _quickButton(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.white,
        elevation: 3,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 17),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAP CONTROL BUTTON
  // ============================================================

  Widget _mapControl(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      elevation: 4,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 45,
          height: 45,
          child: Icon(icon, color: const Color(0xFF444444), size: 22),
        ),
      ),
    );
  }

  // ============================================================
  // LOCATION INFORMATION PANEL
  // ============================================================

  Widget _locationInformation(Map<String, dynamic> location) {
    double? distance;

    if (_currentPosition != null) {
      distance = calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        location['lat'],
        location['lng'],
      );
    }

    final bool isInside = _activeGeofenceId == location['id'];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(Icons.location_on, color: googleBlue, size: 27),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  location['name'],
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedLocationId = null;
                    _searchController.clear();
                    _searchResults = [];
                  });
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          Text(
            location['description'],
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 12),

          const Divider(),

          _informationRow(
            Icons.location_city,
            'Location',
            'Lianga, Surigao del Sur',
          ),

          _informationRow(
            Icons.gps_fixed,
            'Coordinates',
            '${location['lat']}, ${location['lng']}',
          ),

          _informationRow(
            Icons.straighten,
            'Distance',
            distance == null
                ? 'Waiting for GPS...'
                : '${distance.toStringAsFixed(2)} meters',
          ),

          _informationRow(
            Icons.radar,
            'Geofence Radius',
            '${geofenceRadius.toInt()} meters',
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isInside ? Colors.green.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isInside ? Icons.check_circle : Icons.info_outline,
                  color: isInside ? Colors.green : googleBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isInside
                        ? 'You are inside this geofence.'
                        : 'You are outside this geofence.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isInside ? Colors.green.shade800 : googleBlue,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _goToLocation(location['lat'], location['lng']);
              },
              icon: const Icon(Icons.directions),
              label: const Text('Show on Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: googleBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _informationRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 17, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }
}
