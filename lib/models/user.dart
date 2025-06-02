import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String address;
  final String city;
  final String state;
  final String stateCode;
  final String postalCode;
  final Coordinates coordinates;
  final String country;

  const Address({
    required this.address,
    required this.city,
    required this.state,
    required this.stateCode,
    required this.postalCode,
    required this.coordinates,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      stateCode: json['stateCode'] ?? '',
      postalCode: json['postalCode'] ?? '',
      coordinates: Coordinates.fromJson(json['coordinates'] ?? {}),
      country: json['country'] ?? '',
    );
  }

  @override
  List<Object?> get props => [address, city, state, stateCode, postalCode, coordinates, country];
}

class Coordinates extends Equatable {
  final double lat;
  final double lng;

  const Coordinates({required this.lat, required this.lng});

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [lat, lng];
}

class Company extends Equatable {
  final String name;
  final String department;
  final String title;
  final Address address;

  const Company({
    required this.name,
    required this.department,
    required this.title,
    required this.address,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] ?? '',
      department: json['department'] ?? '',
      title: json['title'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [name, department, title, address];
}

class User extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final String username;
  final int age;
  final String gender;
  final String birthDate;
  final String bloodGroup;
  final double height;
  final double weight;
  final String phone;
  final String university;
  final Address address;
  final Company company;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    required this.username,
    required this.age,
    required this.gender,
    required this.birthDate,
    required this.bloodGroup,
    required this.height,
    required this.weight,
    required this.phone,
    required this.university,
    required this.address,
    required this.company,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      image: json['image'] ?? '',
      username: json['username'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      birthDate: json['birthDate'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      height: (json['height'] ?? 0.0).toDouble(),
      weight: (json['weight'] ?? 0.0).toDouble(),
      phone: json['phone'] ?? '',
      university: json['university'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
      company: Company.fromJson(json['company'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'image': image,
      'username': username,
      'age': age,
      'gender': gender,
      'birthDate': birthDate,
      'bloodGroup': bloodGroup,
      'height': height,
      'weight': weight,
      'phone': phone,
      'university': university,
      'address': address,
      'company': company,
    };
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        image,
        username,
        age,
        gender,
        birthDate,
        bloodGroup,
        height,
        weight,
        phone,
        university,
        address,
        company,
      ];
} 