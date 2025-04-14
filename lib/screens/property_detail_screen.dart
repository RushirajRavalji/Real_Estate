import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/property.dart';
import '../widgets/app_drawer.dart';
import 'dart:io';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({Key? key, required this.property})
    : super(key: key);

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _activeImageIndex = 0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController(
    text: "I'm interested in this property",
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String formatPrice(double price) {
    if (widget.property.type == 'rent') {
      return '₹${price.toStringAsFixed(0)}/month';
    } else {
      return '₹${price.toStringAsFixed(0)}';
    }
  }

  String createWhatsAppMessage() {
    final message = '''
Hello, I'm interested in the property: ${widget.property.title}.

Location: ${widget.property.address}, ${widget.property.city}
Price: ${widget.property.price.toStringAsFixed(0)}
Type: ${widget.property.type == 'rent' ? 'For Rent' : 'For Sale'}

My details:
Name: ${_nameController.text}
Email: ${_emailController.text}
Phone: ${_phoneController.text}

${_messageController.text}

Thank you!
''';

    return Uri.encodeComponent(message.trim());
  }

  Future<void> _sendWhatsAppMessage() async {
    try {
      // Agent's WhatsApp number (with country code, no + or spaces)
      const agentPhone = "916354450316";

      // Create the message text
      final messageText = createWhatsAppMessage();

      // Different URL formats for different platforms
      final whatsappUrl = "https://wa.me/$agentPhone?text=$messageText";

      // Create URI
      final Uri uri = Uri.parse(whatsappUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for web
        final webUrl =
            "https://web.whatsapp.com/send?phone=$agentPhone&text=$messageText";
        final webUri = Uri.parse(webUrl);

        if (await canLaunchUrl(webUri)) {
          await launchUrl(
            webUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
        } else {
          throw 'Could not launch WhatsApp';
        }
      }
    } catch (e) {
      debugPrint('WhatsApp launch error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not launch WhatsApp. Make sure the app is installed or try contacting the agent directly.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  // Add a method to make a regular phone call
  Future<void> _makePhoneCall() async {
    const phoneNumber = "+916354450316";
    final Uri uri = Uri.parse("tel:$phoneNumber");

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch phone app';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open phone app'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;
    final isLargeScreen = screenSize.width >= 900;

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back to listings
              Padding(
                padding: EdgeInsets.fromLTRB(
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 12 : 16,
                  isSmallScreen ? 6 : 8,
                ),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: const Color(0xFF6A38F2),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Back to listings',
                        style: TextStyle(
                          color: const Color(0xFF6A38F2),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Property Details - Responsive Layout
              isLargeScreen
                  ? _buildWideLayout(context)
                  : _buildNarrowLayout(context, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  // Wide layout for large screens (desktop, large tablets)
  Widget _buildWideLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - Property details
          Expanded(flex: 2, child: _buildPropertyDetailsCard(false)),

          const SizedBox(width: 24),

          // Right column - Contact form
          Expanded(flex: 1, child: _buildContactForm()),
        ],
      ),
    );
  }

  // Narrow layout for smaller screens (mobile, small tablets)
  Widget _buildNarrowLayout(BuildContext context, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property details
          _buildPropertyDetailsCard(isSmallScreen),

          SizedBox(height: isSmallScreen ? 16 : 24),

          // Contact form
          _buildContactForm(),
        ],
      ),
    );
  }

  // Property details card
  Widget _buildPropertyDetailsCard(bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Section
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.title,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.property.address}, ${widget.property.city}, ${widget.property.state} ${widget.property.zipCode}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                // Tags
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.property.type == 'rent'
                            ? 'For Rent'
                            : 'For Sale',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.indigo[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        widget.property.status.toLowerCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.green[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  formatPrice(widget.property.price),
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6A38F2),
                  ),
                ),
              ],
            ),
          ),

          // Property Image
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    '${widget.property.images[_activeImageIndex]}?auto=format&fit=crop&w=800&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Thumbnail gallery
          if (widget.property.images.length > 1) ...[
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.property.images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeImageIndex = index;
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              _activeImageIndex == index
                                  ? const Color(0xFF6A38F2)
                                  : Colors.transparent,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            '${widget.property.images[index]}?auto=format&fit=crop&w=200&q=80',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Description
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.property.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),

                SizedBox(height: isSmallScreen ? 16 : 24),

                // Property Details
                Text(
                  'Property Details',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // Property Features
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildPropertyDetail(
                      Icons.king_bed_outlined,
                      'Bedrooms',
                      '${widget.property.bedrooms}',
                    ),
                    _buildPropertyDetail(
                      Icons.bathtub_outlined,
                      'Bathrooms',
                      '${widget.property.bathrooms}',
                    ),
                    _buildPropertyDetail(
                      Icons.straighten_outlined,
                      'Square Feet',
                      '${widget.property.squareFeet}',
                    ),
                    _buildPropertyDetail(
                      Icons.location_on_outlined,
                      'Location',
                      '${widget.property.city}, ${widget.property.state}',
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

  // Contact form card
  Widget _buildContactForm() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Agent',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Name field
          const Text(
            'Your Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
          const SizedBox(height: 16),

          // Email field
          const Text(
            'Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Enter your email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),

          const SizedBox(height: 16),

          // Phone number field
          const Text(
            'Phone Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter your phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),

          const SizedBox(height: 16),

          // Message field
          const Text(
            'Message',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Your message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),

          const SizedBox(height: 16),

          // Add the contact buttons to the bottom of the form
          _buildContactButtons(),
        ],
      ),
    );
  }

  // Add the contact buttons to the bottom of the form
  Widget _buildContactButtons() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Contact the agent directly:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // WhatsApp button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _sendWhatsAppMessage,
                icon: const Icon(Icons.message),
                label: const Text('WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // WhatsApp green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Call button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _makePhoneCall,
                icon: const Icon(Icons.phone),
                label: const Text('Call'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A38F2), // DreamHome purple
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPropertyDetail(IconData icon, String label, String value) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return SizedBox(
      width: isSmallScreen ? double.infinity : null,
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF6A38F2), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
