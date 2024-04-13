class User {
    final String? accessToken; // Add this line
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String username;
  final String createdAt;
  final String updatedAt;
  final String? image;
  final String? status;
  final String? lastSeen;
  final String? emailVerifiedAt;
  final String? deletedAt;

  User({
        this.accessToken, // Add this line
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
    this.image,
    this.status,
    this.lastSeen,
    this.emailVerifiedAt,
    this.deletedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
            accessToken: json['access_token'], // Add this line
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      username: json['username'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      image: json['image'],
      status: json['status'],
      lastSeen: json['last_seen'],
      emailVerifiedAt: json['email_verified_at'],
      deletedAt: json['deleted_at'],
    );
  }


  

  Map<String, dynamic> toJson() {
    final map = {
            'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'username': username,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'image': image,
      'status': status,
      'last_seen': lastSeen,
      'email_verified_at': emailVerifiedAt,
      'deleted_at': deletedAt,
    };

    if (accessToken != null) {
      map['access_token'] = accessToken; // Add this line
    }

    return map;
  }






}
