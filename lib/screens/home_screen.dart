import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../services/property_service.dart';
import 'property_listing_screen.dart';
import 'property_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const routeName = '/home';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PropertyService _propertyService = PropertyService();

  final _propertyTypes = [
    'All Properties',
    'Apartments',
    'Houses',
    'Villas',
    'Commercial',
  ];

  final _bedroomOptions = ['Any', '1', '2', '3', '4+'];

  String _selectedPropertyType = 'All Properties';
  String _selectedBedrooms = 'Any';
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize property data when home screen loads
    _initializeData();
  }

  Future<void> _initializeData() async {
    // Initialize properties collection if empty
    await _propertyService.checkAndSeedProperties();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      key: _scaffoldKey,
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
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF6A38F2)),
          onPressed: () {
            _scaffoldKey.currentState
                ?.openDrawer(); // Changed to standard drawer (from top)
          },
        ),
      ),
      drawer: const AppDrawer(), // Changed to standard drawer (from top)
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Section with background image - responsive height
            Container(
              height:
                  isLandscape
                      ? screenSize.height * 0.7
                      : isSmallScreen
                      ? screenSize.height * 0.4
                      : screenSize.height * 0.45,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1582407947304-fd86f028f716?q=80&w=1200&auto=format',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black45,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Find Your Dream Home',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 24 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 16),
                    Text(
                      'Discover thousands of properties for sale and rent across the country. Your perfect home is just a click away.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    // Action buttons - responsive width
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? double.infinity : 500,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const PropertyListingScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A38F2),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 12 : 16,
                                ),
                              ),
                              child: const Text('Browse Properties for Sale'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? double.infinity : 500,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const PropertyListingScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 12 : 16,
                                ),
                              ),
                              child: const Text(
                                'Find Rentals',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Form
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // For wider screens, use a grid layout
                  if (constraints.maxWidth > 700) {
                    return _buildWideSearchForm();
                  } else {
                    return _buildNarrowSearchForm(isSmallScreen);
                  }
                },
              ),
            ),

            // Property listings header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12.0 : 16.0,
                vertical: isSmallScreen ? 4.0 : 8.0,
              ),
              child: Text(
                'Property Listings',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            // Featured Properties section
            _buildFeaturedProperties(isSmallScreen),

            // Browse More button
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PropertyListingScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A38F2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 16.0,
                    ),
                  ),
                  child: const Text(
                    'Browse All Properties',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Add some spacing at the bottom
            SizedBox(height: isSmallScreen ? 16.0 : 32.0),
          ],
        ),
      ),
    );
  }

  // Search form for wider screens (tablet, desktop)
  Widget _buildWideSearchForm() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Find Your Dream Home',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Grid layout for search form
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First column - Property Type and Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Type
                    _buildFormLabel('Property Type'),
                    _buildPropertyTypeDropdown(),
                    const SizedBox(height: 16),

                    // Location
                    _buildFormLabel('Location'),
                    _buildLocationField(),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Second column - Min/Max Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Min Price
                    _buildFormLabel('Min Price'),
                    _buildMinPriceField(),
                    const SizedBox(height: 16),

                    // Max Price
                    _buildFormLabel('Max Price'),
                    _buildMaxPriceField(),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Third column - Bedrooms and Search button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bedrooms
                    _buildFormLabel('Bedrooms'),
                    _buildBedroomsDropdown(),
                    const SizedBox(height: 16),

                    // Search Button - aligned with other fields
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: _buildSearchButton(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Search form for narrower screens (mobile)
  Widget _buildNarrowSearchForm(bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.only(top: isSmallScreen ? 4 : 8),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
            child: Text(
              'Find Your Dream Home',
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Property Type
          _buildFormLabel('Property Type'),
          _buildPropertyTypeDropdown(),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Location
          _buildFormLabel('Location'),
          _buildLocationField(),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Min Price
          _buildFormLabel('Min Price'),
          _buildMinPriceField(),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Max Price
          _buildFormLabel('Max Price'),
          _buildMaxPriceField(),
          SizedBox(height: isSmallScreen ? 12 : 16),

          // Bedrooms
          _buildFormLabel('Bedrooms'),
          _buildBedroomsDropdown(),
          SizedBox(height: isSmallScreen ? 16 : 24),

          // Search Button
          _buildSearchButton(),
        ],
      ),
    );
  }

  // Helper methods for form elements
  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPropertyTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedPropertyType,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        items:
            _propertyTypes.map((String type) {
              return DropdownMenuItem<String>(value: type, child: Text(type));
            }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedPropertyType = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildLocationField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _locationController,
        decoration: const InputDecoration(
          hintText: 'City, State or ZIP',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMinPriceField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _minPriceController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Min Price',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMaxPriceField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _maxPriceController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Max Price',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBedroomsDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedBedrooms,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
        items:
            _bedroomOptions.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedBedrooms = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PropertyListingScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6A38F2),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Search Properties'),
      ),
    );
  }

  // Method to build the featured properties section
  Widget _buildFeaturedProperties(bool isSmallScreen) {
    return SizedBox(
      height: 330,
      child: StreamBuilder(
        stream: _propertyService.getPropertiesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final properties = snapshot.data ?? [];

          if (properties.isEmpty) {
            return const Center(child: Text('No properties available'));
          }

          // Take only the first 3-5 properties
          final featuredProperties = properties.take(5).toList();

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12.0 : 16.0,
              vertical: 16.0,
            ),
            itemCount: featuredProperties.length,
            itemBuilder: (context, index) {
              final property = featuredProperties[index];
              return _buildPropertyCard(context, property, isSmallScreen);
            },
          );
        },
      ),
    );
  }

  // Method to build a property card for the horizontal list
  Widget _buildPropertyCard(
    BuildContext context,
    property,
    bool isSmallScreen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(property: property),
          ),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
              child: SizedBox(
                height: 160,
                width: double.infinity,
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
                            : _propertyService.base64ToImage(property.images[0])
                        : Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.cover,
                        ),
              ),
            ),

            // Property details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property title
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4.0),

                  // Property location
                  Text(
                    '${property.address}, ${property.city}',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8.0),

                  // Property price
                  Text(
                    property.type == 'rent'
                        ? '₹${property.price.toStringAsFixed(0)}/month'
                        : '₹${property.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A38F2),
                    ),
                  ),

                  const SizedBox(height: 8.0),

                  // Property features
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFeature(Icons.bed, '${property.bedrooms} Beds'),
                      _buildFeature(
                        Icons.bathroom,
                        '${property.bathrooms} Baths',
                      ),
                      _buildFeature(
                        Icons.square_foot,
                        '${property.squareFeet} sqft',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a feature item
  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.0, color: Colors.grey[600]),
        const SizedBox(width: 4.0),
        Text(text, style: TextStyle(fontSize: 12.0, color: Colors.grey[600])),
      ],
    );
  }
}
