import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/property_service.dart';
import '../widgets/app_drawer.dart';
import 'property_detail_screen.dart';

class PropertyListingScreen extends StatefulWidget {
  const PropertyListingScreen({Key? key}) : super(key: key);

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PropertyService _propertyService = PropertyService();

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'DreamHome',
          style: TextStyle(
            color: Color(0xFF6A38F2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF6A38F2)),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Changed to standard drawer (from top)
          },
        ),
      ),
      drawer: const AppDrawer(), // Changed to standard drawer (from top)
      body: SafeArea(
        child: StreamBuilder<List<Property>>(
          stream: _propertyService.getPropertiesStream(),
          builder: (context, snapshot) {
            debugPrint(
              'Property listing stream state: ${snapshot.connectionState}',
            );

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              debugPrint('Error in property listing: ${snapshot.error}');
              return Center(
                child: Text(
                  'Error loading properties: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            final properties = snapshot.data ?? [];
            debugPrint('Properties loaded: ${properties.length}');

            if (properties.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No properties available at the moment',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Refresh the page
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A38F2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Listings Header
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                    child: Text(
                      'Property Listings',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  // Property List - responsive grid for larger screens
                  if (isSmallScreen)
                    _buildListView(properties)
                  else
                    _buildGridView(properties, isMediumScreen ? 2 : 3),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // List view for small screens
  Widget _buildListView(List<Property> properties) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        return _buildPropertyCard(context, properties[index]);
      },
    );
  }

  // Grid view for larger screens
  Widget _buildGridView(List<Property> properties, int crossAxisCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          return _buildPropertyCardGrid(context, properties[index]);
        },
      ),
    );
  }

  // Property card for list view
  Widget _buildPropertyCard(BuildContext context, Property property) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16, left: 12, right: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property image with tags
          Stack(
            children: [
              // Property image
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child:
                      property.images.isNotEmpty
                          ? property.images[0].startsWith('http')
                              ? Image.network(
                                property.images[0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                              : _propertyService.base64ToImage(
                                property.images[0],
                              )
                          : Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                ),
              ),

              // Tags - Featured and For Sale/Rent
              Positioned(
                top: 12,
                left: 12,
                child: Row(
                  children: [
                    if (property.isFeatured)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            property.type == 'sale'
                                ? Colors.blue
                                : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        property.type == 'sale' ? 'For Sale' : 'For Rent',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Property Details
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Price
                    Text(
                      property.type == 'rent'
                          ? '₹${property.price.toStringAsFixed(0)}/month'
                          : '₹${property.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A38F2),
                      ),
                    ),
                  ],
                ),

                // Address
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    '${property.address}, ${property.city}, ${property.state} ${property.zipCode}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Description
                Text(
                  property.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 16),

                // Property Features
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildFeature(
                      Icons.king_bed_outlined,
                      '${property.bedrooms} Beds',
                    ),
                    _buildFeature(
                      Icons.bathtub_outlined,
                      '${property.bathrooms} Baths',
                    ),
                    _buildFeature(
                      Icons.straighten_outlined,
                      '${property.squareFeet} sqft',
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // View Details Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  PropertyDetailScreen(property: property),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A38F2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Property card for grid view (more compact)
  Widget _buildPropertyCardGrid(BuildContext context, Property property) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property image with price tag
          Stack(
            children: [
              // Property image
              SizedBox(
                height: 140,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child:
                      property.images.isNotEmpty
                          ? property.images[0].startsWith('http')
                              ? Image.network(
                                property.images[0],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/placeholder.png',
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                              : _propertyService.base64ToImage(
                                property.images[0],
                              )
                          : Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          ),
                ),
              ),

              // Price tag
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    property.type == 'rent'
                        ? '₹${property.price.toStringAsFixed(0)}/month'
                        : '₹${property.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Tags - For Sale/Rent
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: property.type == 'sale' ? Colors.blue : Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    property.type == 'sale' ? 'Sale' : 'Rent',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Property Details
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Address
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${property.address}, ${property.city}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const Spacer(),

                  // Property Features
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFeatureCompact(
                        Icons.king_bed_outlined,
                        '${property.bedrooms}',
                      ),
                      _buildFeatureCompact(
                        Icons.bathtub_outlined,
                        '${property.bathrooms}',
                      ),
                      _buildFeatureCompact(
                        Icons.straighten_outlined,
                        '${property.squareFeet}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // View Details Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PropertyDetailScreen(property: property),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A38F2),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildFeatureCompact(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 2),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
