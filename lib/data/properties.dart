import '../models/property.dart';

final List<Property> properties = [
  Property(
    id: 'prop-1',
    title: 'Modern Apartment in Ahmedabad',
    description:
        'Beautiful apartment with amazing views of the Sabarmati Riverfront. Recently renovated with high-end finishes.',
    price: 4500000,
    address: '123 SG Highway',
    city: 'Ahmedabad',
    state: 'Gujarat',
    zipCode: '380054',
    type: 'sale',
    status: 'Available',
    bedrooms: 2,
    bathrooms: 2,
    squareFeet: 1200,
    images: [
      'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
      'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
      'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2',
    ],
  ),
  Property(
    id: 'prop-2',
    title: 'Luxury Villa in Goa',
    description:
        'Spacious seaside villa with private access to beach. Features include swimming pool, modern interiors, and 24-hour security.',
    price: 15000000,
    address: '45 Beach Road',
    city: 'Panjim',
    state: 'Goa',
    zipCode: '403001',
    type: 'sale',
    status: 'Available',
    bedrooms: 4,
    bathrooms: 4,
    squareFeet: 3500,
    images: [
      'https://images.unsplash.com/photo-1564013799919-ab600027ffc6',
      'https://images.unsplash.com/photo-1576941089067-2de3c901e126',
      'https://images.unsplash.com/photo-1592595896551-12b371d546d5',
    ],
  ),
  Property(
    id: 'prop-3',
    title: 'Premium Flat for Rent',
    description:
        'Fully furnished 3-bedroom flat in a gated society. Modern amenities, reserved parking, and close to major tech parks.',
    price: 50000,
    address: '78 Whitefield Main Road',
    city: 'Bangalore',
    state: 'Karnataka',
    zipCode: '560066',
    type: 'rent',
    status: 'Available',
    bedrooms: 3,
    bathrooms: 2,
    squareFeet: 1800,
    images: [
      'https://images.unsplash.com/photo-1493809842364-78817add7ffb',
      'https://images.unsplash.com/photo-1502005097973-6a7082348e28',
      'https://images.unsplash.com/photo-1560185007-cde436f6a4d0',
    ],
  ),
];
