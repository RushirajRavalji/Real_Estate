import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String type; // 'rent' or 'sale'
  final String status; // 'available', 'pending', 'sold'
  final int bedrooms;
  final int bathrooms;
  final double squareFeet;
  final List<String> images;
  final bool isFeatured;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.type,
    required this.status,
    required this.bedrooms,
    required this.bathrooms,
    required this.squareFeet,
    required this.images,
    this.isFeatured = false,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Create a property from a Firestore document
  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      zipCode: map['zipCode'] ?? '',
      type: map['type'] ?? 'sale',
      status: map['status'] ?? 'available',
      bedrooms: map['bedrooms'] ?? 0,
      bathrooms: map['bathrooms'] ?? 0,
      squareFeet: (map['squareFeet'] ?? 0.0).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      isFeatured: map['isFeatured'] ?? false,
      userId: map['userId'],
      createdAt:
          map['createdAt'] != null
              ? (map['createdAt'] as Timestamp).toDate()
              : null,
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : null,
    );
  }

  // Convert the property to a map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'type': type,
      'status': status,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'squareFeet': squareFeet,
      'images': images,
      'isFeatured': isFeatured,
      'userId': userId,
      // We don't include id, createdAt, or updatedAt as they are managed by Firestore
    };
  }

  // Create a copy of this property with the given fields replaced with the new values
  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? type,
    String? status,
    int? bedrooms,
    int? bathrooms,
    double? squareFeet,
    List<String>? images,
    bool? isFeatured,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      type: type ?? this.type,
      status: status ?? this.status,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      squareFeet: squareFeet ?? this.squareFeet,
      images: images ?? this.images,
      isFeatured: isFeatured ?? this.isFeatured,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
