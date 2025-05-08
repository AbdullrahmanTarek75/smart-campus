import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/campus_map_controller.dart';

class MapSettingsPanel extends StatelessWidget {
  const MapSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final mapController = Provider.of<CampusMapController>(context);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar at top
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Map Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Settings content (scrollable)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Map Display Section
                  _buildSectionHeader('Map Display', Icons.map, context),
                  const SizedBox(height: 12),
                  
                  // Building Labels Setting
                  _buildSettingCard(
                    context,
                    icon: Icons.label,
                    title: 'Building Labels',
                    subtitle: 'Show or hide building names on the map',
                    trailing: Switch(
                      value: mapController.showBuildingLabels,
                      onChanged: (_) => mapController.toggleBuildingLabels(),
                      activeColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Offline Maps Section
                  _buildSectionHeader('Offline Maps', Icons.cloud_download, context),
                  const SizedBox(height: 12),
                  
                  // Offline mode status card
                  _buildSettingCard(
                    context,
                    icon: mapController.offlineModeAvailable 
                        ? Icons.check_circle 
                        : Icons.cloud_download_outlined,
                    iconColor: mapController.offlineModeAvailable
                        ? Colors.green
                        : null,
                    title: 'Offline Map Data',
                    subtitle: mapController.offlineModeAvailable
                        ? 'Map data is available for offline use'
                        : 'Download map data to use without internet',
                    trailing: mapController.isDownloadingMapTiles
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : null,
                  ),
                  
                  // Download progress (if downloading)
                  if (mapController.isDownloadingMapTiles) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Downloading: ${(mapController.downloadProgress * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: mapController.downloadProgress,
                      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                  
                  // Download button (if not downloaded or downloading)
                  if (!mapController.offlineModeAvailable && !mapController.isDownloadingMapTiles) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          mapController.downloadMapTilesForOfflineUse();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Downloading map data for offline use...'),
                              backgroundColor: Theme.of(context).primaryColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download Map Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Location Section
                  _buildSectionHeader('Location', Icons.location_on, context),
                  const SizedBox(height: 12),
                  
                  // Location permissions status
                  _buildSettingCard(
                    context,
                    icon: mapController.isLocationEnabled
                        ? Icons.location_on
                        : Icons.location_off,
                    iconColor: mapController.isLocationEnabled
                        ? Colors.green
                        : Colors.red,
                    title: 'Location Services',
                    subtitle: mapController.isLocationEnabled
                        ? 'Your location is being tracked on the map'
                        : 'Location access is required for navigation',
                    trailing: mapController.isLocationEnabled
                        ? Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24,
                          )
                        : null,
                  ),
                  
                  // Location permission button
                  if (!mapController.isLocationEnabled) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await mapController.getCurrentLocation();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.location_searching),
                        label: const Text('Enable Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // About section
                  _buildSectionHeader('About', Icons.info_outline, context),
                  const SizedBox(height: 12),
                  
                  _buildSettingCard(
                    context,
                    icon: Icons.school,
                    title: 'Campus Map',
                    subtitle: 'Version 1.0.0',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build section headers
  Widget _buildSectionHeader(String title, IconData icon, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
  
  // Helper method to build settings cards
  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 0,
      color: isDarkMode ? Colors.grey[800] : Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (iconColor ?? Theme.of(context).primaryColor).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
} 