import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:real_estate_app/models/property.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // User authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Authentication methods
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      throw Exception('Authentication failed: ${e.toString()}');
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'createdAt': Timestamp.now(),
      });

      return userCredential;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Firestore methods for properties
  Future<List<Property>> getProperties() async {
    try {
      final snapshot = await _firestore.collection('properties').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Property.fromMap({...data, 'id': doc.id});
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch properties: ${e.toString()}');
    }
  }

  Future<Property> getPropertyById(String id) async {
    try {
      final doc = await _firestore.collection('properties').doc(id).get();
      if (!doc.exists) {
        throw Exception('Property not found');
      }

      final data = doc.data()!;
      return Property.fromMap({...data, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to fetch property: ${e.toString()}');
    }
  }

  Future<String> addProperty(Property property, List<Image> images) async {
    try {
      // Convert images to base64
      List<String> base64Images = [];
      for (var image in images) {
        // In a real implementation, you would convert the image to base64
        // This is a placeholder
        base64Images.add('base64_image_placeholder');
      }

      // Create property map
      final propertyMap = property.toMap();
      propertyMap['images'] = base64Images;
      propertyMap['userId'] = currentUser?.uid;
      propertyMap['createdAt'] = Timestamp.now();

      // Add to Firestore
      final docRef = await _firestore.collection('properties').add(propertyMap);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add property: ${e.toString()}');
    }
  }

  Future<void> updateProperty(Property property, List<Image>? newImages) async {
    try {
      final propertyMap = property.toMap();

      // If new images are provided, convert them to base64
      if (newImages != null && newImages.isNotEmpty) {
        List<String> base64Images = [];
        for (var image in newImages) {
          // In a real implementation, you would convert the image to base64
          // This is a placeholder
          base64Images.add('base64_image_placeholder');
        }
        propertyMap['images'] = base64Images;
      }

      propertyMap['updatedAt'] = Timestamp.now();

      await _firestore
          .collection('properties')
          .doc(property.id)
          .update(propertyMap);
    } catch (e) {
      throw Exception('Failed to update property: ${e.toString()}');
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      await _firestore.collection('properties').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete property: ${e.toString()}');
    }
  }

  // Methods for user's favorite properties
  Future<void> addPropertyToFavorites(String propertyId) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(propertyId)
          .set({'propertyId': propertyId, 'addedAt': Timestamp.now()});
    } catch (e) {
      throw Exception('Failed to add property to favorites: ${e.toString()}');
    }
  }

  Future<void> removePropertyFromFavorites(String propertyId) async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(propertyId)
          .delete();
    } catch (e) {
      throw Exception(
        'Failed to remove property from favorites: ${e.toString()}',
      );
    }
  }

  Future<List<String>> getFavoritePropertyIds() async {
    try {
      final userId = currentUser?.uid;
      if (userId == null) {
        return [];
      }

      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('favorites')
              .get();
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite properties: ${e.toString()}');
    }
  }

  // Helper method to convert Image widget to base64 string
  // This is a placeholder - actual implementation would depend on how images are handled
  String _imageToBase64(Image image) {
    // In a real implementation, you would convert the image to base64
    return 'base64_image_placeholder';
  }
}
