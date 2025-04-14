import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/property.dart';
import '../data/properties.dart';

class PropertyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _propertiesCollection =>
      _firestore.collection('properties');

  // Check if properties collection is empty and seed with sample data
  Future<void> checkAndSeedProperties() async {
    try {
      // Check if collection is empty
      final snapshot = await _propertiesCollection.limit(1).get();

      if (snapshot.docs.isEmpty) {
        debugPrint('Seeding properties collection with sample data...');

        // Add sample properties from the properties.dart file
        for (var property in properties) {
          await _propertiesCollection.add({
            'title': property.title,
            'description': property.description,
            'price': property.price,
            'address': property.address,
            'city': property.city,
            'state': property.state,
            'zipCode': property.zipCode,
            'type': property.type,
            'status': property.status,
            'bedrooms': property.bedrooms,
            'bathrooms': property.bathrooms,
            'squareFeet': property.squareFeet,
            'images': property.images,
            'isFeatured': property.isFeatured ?? false,
            'userId': _auth.currentUser?.uid,
            'createdAt': Timestamp.now(),
          });
        }

        debugPrint(
          'Successfully seeded properties collection with ${properties.length} properties',
        );
      }
    } catch (e) {
      debugPrint('Error seeding properties: $e');
    }
  }

  // Get stream of all properties
  Stream<List<Property>> getPropertiesStream() {
    try {
      debugPrint('Getting properties stream...');
      // First check if we need to seed data
      checkAndSeedProperties();

      return _propertiesCollection.snapshots().map((snapshot) {
        final list =
            snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Property.fromMap({...data, 'id': doc.id});
            }).toList();

        debugPrint('Retrieved ${list.length} properties from Firestore');
        return list;
      });
    } catch (e) {
      debugPrint('Error in getPropertiesStream: $e');
      return Stream.value([]);
    }
  }

  // Get properties by type (sale/rent)
  Stream<List<Property>> getPropertiesByTypeStream(String type) {
    return _propertiesCollection
        .where('type', isEqualTo: type)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Property.fromMap({...data, 'id': doc.id});
          }).toList();
        });
  }

  // Get properties owned by current user
  Stream<List<Property>> getMyPropertiesStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }

    try {
      return _propertiesCollection
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Property.fromMap({...data, 'id': doc.id});
            }).toList();
          });
    } catch (e) {
      debugPrint('Error in getMyPropertiesStream: $e');
      return Stream.value([]);
    }
  }

  // Get a property by ID
  Future<Property?> getPropertyById(String id) async {
    final doc = await _propertiesCollection.doc(id).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Property.fromMap({...data, 'id': doc.id});
    }
    return null;
  }

  // Create a new property
  Future<String> createProperty(Property property) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Add owner ID and creation date
      final propertyWithOwner = property.copyWith(
        userId: userId,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final docRef = await _propertiesCollection.add(propertyWithOwner.toMap());
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Update a property
  Future<void> updateProperty(Property property) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if the user is the owner
      final existingProperty = await getPropertyById(property.id);
      if (existingProperty == null) {
        throw Exception('Property not found');
      }
      if (existingProperty.userId != userId) {
        throw Exception('You are not authorized to update this property');
      }

      // Update the property
      await _propertiesCollection.doc(property.id).update(property.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Delete a property
  Future<void> deleteProperty(String id) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Check if the user is the owner
      final existingProperty = await getPropertyById(id);
      if (existingProperty == null) {
        throw Exception('Property not found');
      }
      if (existingProperty.userId != userId) {
        throw Exception('You are not authorized to delete this property');
      }

      // Delete the property
      await _propertiesCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Convert XFile to base64 encoded string
  Future<String> imageToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      rethrow;
    }
  }

  // Convert base64 to image
  Image base64ToImage(String base64String) {
    try {
      final bytes = base64Decode(base64String);
      return Image.memory(Uint8List.fromList(bytes), fit: BoxFit.cover);
    } catch (e) {
      // Return a placeholder image if there's an error
      return Image.asset('assets/images/placeholder.png', fit: BoxFit.cover);
    }
  }

  // Pick images from gallery and convert to base64
  Future<List<String>> pickAndEncodeImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 70, // Reduce quality to save space
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (images.isEmpty) {
        return [];
      }

      // Convert all images to base64
      final List<String> base64Images = [];
      for (final image in images) {
        final base64String = await imageToBase64(image);
        base64Images.add(base64String);
      }

      return base64Images;
    } catch (e) {
      rethrow;
    }
  }

  // Filter properties by criteria
  Future<List<Property>> filterProperties({
    String? type,
    int? minBedrooms,
    int? maxBedrooms,
    double? minPrice,
    double? maxPrice,
    String? city,
  }) async {
    try {
      Query query = _propertiesCollection;

      // Apply filters
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }

      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      // Get all properties that match the filter
      final snapshot = await query.get();
      final List<Property> properties =
          snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Property.fromMap({...data, 'id': doc.id});
          }).toList();

      // Apply additional filters (because Firestore can't handle multiple range queries)
      return properties.where((property) {
        // Filter by min bedrooms
        if (minBedrooms != null && property.bedrooms < minBedrooms) {
          return false;
        }

        // Filter by max bedrooms
        if (maxBedrooms != null && property.bedrooms > maxBedrooms) {
          return false;
        }

        // Filter by min price
        if (minPrice != null && property.price < minPrice) {
          return false;
        }

        // Filter by max price
        if (maxPrice != null && property.price > maxPrice) {
          return false;
        }

        return true;
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
