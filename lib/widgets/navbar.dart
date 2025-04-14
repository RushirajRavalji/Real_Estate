import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child:
          isMobile ? _buildMobileNavbar(context) : _buildDesktopNavbar(context),
    );
  }

  Widget _buildDesktopNavbar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Row(
          children: [
            Icon(Icons.home, color: Colors.indigo[600], size: 24),
            const SizedBox(width: 8),
            Text(
              'Real Estate App',
              style: TextStyle(
                color: Colors.indigo[800],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),

        // Menu
        Row(
          children: [
            _buildNavItem('Home', true),
            _buildNavItem('Properties', false),
            _buildNavItem('Contact', false),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileNavbar(BuildContext context) {
    return Column(
      children: [
        // Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, color: Colors.indigo[600], size: 24),
            const SizedBox(width: 8),
            Text(
              'Real Estate App',
              style: TextStyle(
                color: Colors.indigo[800],
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Menu
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNavItem('Home', true),
            _buildNavItem('Properties', false),
            _buildNavItem('Contact', false),
          ],
        ),
      ],
    );
  }

  Widget _buildNavItem(String title, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.indigo[600] : Colors.black87,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
