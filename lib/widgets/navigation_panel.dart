import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/campus_map_controller.dart';

class NavigationPanel extends StatelessWidget {
  const NavigationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final mapController = Provider.of<CampusMapController>(context);
    
    // Always return empty container - completely remove the navigation panel
    return const SizedBox.shrink();
  }
} 