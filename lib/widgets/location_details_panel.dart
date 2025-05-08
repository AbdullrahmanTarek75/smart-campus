import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/campus_map_controller.dart';
import '../models/location_model.dart';

class LocationDetailsPanel extends StatelessWidget {
  const LocationDetailsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mapController = Provider.of<CampusMapController>(context);
    
    // If no location is selected or user is navigating, don't show this panel
    if (mapController.selectedLocation == null || mapController.isNavigating) {
      return const SizedBox.shrink();
    }
    
    final LocationModel location = mapController.selectedLocation!;
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with colored background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getColorForLocation(location, isDarkMode).withOpacity(0.1),
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getIconForLocation(location),
                    color: _getColorForLocation(location, isDarkMode),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getLocationSubtitle(location),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => mapController.selectLocation(null),
                ),
              ],
            ),
          ),
          
          // Details in card body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Details section
                if (location.description.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          location.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Features row
                Row(
                  children: [
                    // Capacity
                    if (location.capacity != null) ...[
                      _buildFeatureItem(
                        context,
                        Icons.people,
                        '${location.capacity}',
                        'Capacity',
                        isDarkMode,
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    // Floors
                    if (location.type == 'building' && location.floors != null) ...[
                      _buildFeatureItem(
                        context,
                        Icons.layers,
                        '${location.floors}',
                        'Floors',
                        isDarkMode,
                      ),
                      const SizedBox(width: 16),
                    ],
                    
                    // Floor number
                    if (location.type == 'room' && location.floor != null) ...[
                      _buildFeatureItem(
                        context,
                        Icons.stairs,
                        '${location.floor}',
                        'Floor',
                        isDarkMode,
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  children: [
                    // Navigate button
                    if (mapController.currentLatLng != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.directions),
                          label: const Text('Navigate'),
                          onPressed: () => mapController.startNavigation(location.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    
                    // Add space between buttons
                    if (mapController.currentLatLng != null &&
                        location.type == 'building' &&
                        location.floors != null)
                      const SizedBox(width: 12),
                    
                    // Explore button for buildings
                    if (location.type == 'building' && location.floors != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.explore),
                          label: const Text('Explore'),
                          onPressed: () {
                            // Show floor selection
                            _showFloorSelectionBottomSheet(context, location, mapController);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor,
                            side: BorderSide(color: Theme.of(context).primaryColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build feature items
  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Text(
            '$value $label',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper to show floor selection bottom sheet
  void _showFloorSelectionBottomSheet(
    BuildContext context,
    LocationModel building,
    CampusMapController controller,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final floors = List<int>.generate(
      building.floors ?? 1,
      (index) => index + 1,
    );
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Explore ${building.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a floor to view',
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: floors.map((floor) {
                  final isSelected = controller.selectedFloor == floor;
                  return InkWell(
                    onTap: () {
                      controller.setSelectedFloor(floor);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'F$floor',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : (isDarkMode ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _getLocationSubtitle(LocationModel location) {
    if (location.type == 'room' && location.building != null) {
      return '${location.building}, Floor ${location.floor ?? 1}';
    } else if (location.type == 'building' && location.floors != null) {
      return '${location.floors} floors building';
    } else if (location.type == 'poi') {
      return 'Point of Interest';
    } else {
      return location.type.toUpperCase();
    }
  }
  
  IconData _getIconForLocation(LocationModel location) {
    switch (location.type) {
      case 'room':
        return Icons.meeting_room;
      case 'building':
        return Icons.business;
      case 'poi':
        if (location.id.contains('cafe')) return Icons.restaurant;
        if (location.id.contains('parking')) return Icons.local_parking;
        if (location.id.contains('sport')) return Icons.sports;
        if (location.id.contains('library')) return Icons.menu_book;
        return Icons.place;
      default:
        return Icons.location_on;
    }
  }
  
  Color _getColorForLocation(LocationModel location, bool isDarkMode) {
    switch (location.type) {
      case 'room':
        return Colors.blue;
      case 'building':
        return Colors.green;
      case 'poi':
        if (location.id.contains('cafe')) return Colors.amber;
        if (location.id.contains('parking')) return Colors.blueGrey;
        if (location.id.contains('sport')) return Colors.orange;
        if (location.id.contains('library')) return Colors.indigo;
        return Colors.amber;
      default:
        return Colors.red;
    }
  }
} 