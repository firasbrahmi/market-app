class CompanyDetails {
  final int id;
  final String name;
    final String? image;
  final String slug;
  // Add other fields as needed

  CompanyDetails({
    required this.id,
    required this.name,
        this.image,
    required this.slug,
    // Initialize other fields
  });

  factory CompanyDetails.fromJson(Map<String, dynamic> json) {
    return CompanyDetails(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      slug: json['slug'],
      // Map other fields
    );
  }
}

class UserCompany {
  final CompanyDetails details;

  UserCompany({required this.details});

  factory UserCompany.fromJson(Map<String, dynamic> json) {
    return UserCompany(
      details: CompanyDetails.fromJson(json['details']),
    );
  }
}
