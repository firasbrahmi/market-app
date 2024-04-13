class AssignmentDetail {
  final int id;
  final String slug;
  final int marketId;
  final int vendorId;
  final int vehicleId;
  final String day;
  final String? startTime;
  final String? endTime;
  final String status;
  final int companyId;

  final Market market;
  final Vehicle vehicle;
  final List<AssignedProduct> assignedProducts;
  final List<Equipment> equipments;

  AssignmentDetail({
    required this.id,
    required this.slug,
    required this.marketId,
    required this.vendorId,
    required this.vehicleId,
    required this.day,
    this.startTime,
    this.endTime,
    required this.status,
    required this.companyId,
    required this.market,
    required this.vehicle,
    required this.assignedProducts,
    required this.equipments,
  });

  factory AssignmentDetail.fromJson(Map<String, dynamic> json) {

    var assignmentJson = json['assignment'];

    var productsList = assignmentJson['api_assigned_products'] as List;

    var equipmentsJson = json['equipments'] as List;
    print("Equipments JSON: $equipmentsJson");

    List<AssignedProduct> products = productsList.map((i) => AssignedProduct.fromJson(i)).toList();
    List<Equipment> equipments = equipmentsJson.map((i) => Equipment.fromJson(i)).toList();

    print("Parsed Equipments: $equipments");

    return AssignmentDetail(
      id: assignmentJson['id'],
      slug: assignmentJson['slug'],
      marketId: assignmentJson['market_id'],
      vendorId: assignmentJson['vendor_id'],
      vehicleId: assignmentJson['vehicle_id'],
      day: assignmentJson['day'],
      startTime: assignmentJson['start_time'],
      endTime: assignmentJson['end_time'],
      status: assignmentJson['status'],
      companyId: assignmentJson['company_id'],
      market: Market.fromJson(assignmentJson['market']),
      vehicle: Vehicle.fromJson(assignmentJson['vehicle']),
      assignedProducts: products,
      equipments: equipments,
    );
  }
}





class AssignedProduct {
  final int productId;
  final int quantity;
  final String price;
  final int sold;
  final int extra;
  final int missing;
  final Product product;

  AssignedProduct({
    required this.productId,
    required this.quantity,
    required this.price,
    required this.sold,
    required this.extra,
    required this.missing,
    required this.product,
  });

  factory AssignedProduct.fromJson(Map<String, dynamic> json) {
    return AssignedProduct(
      productId: json['product_id'],
      quantity: json['quantity'],
      price: json['price'],
      sold: json['sold'],
      extra: json['extra'],
      missing: json['missing'],
      product: Product.fromJson(json['product']),
    );
  }
}

class Product {
  final int id;
  final String name;
  final String? image;
  final String description;

  Product({required this.id, required this.name, this.image, required this.description});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
    );
  }
}




class Equipment {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final String? description;
  final int stock;
  final String? status;
  final DateTime? lastMaintenance;
  final int? companyId;
  final int amount; // assuming amount is always present

  Equipment({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.description,
    required this.stock,
    this.status,
    this.lastMaintenance,
    this.companyId,
    required this.amount,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      image: json['image'],
      description: json['description'],
      stock: json['stock'],
      status: json['status'],
      lastMaintenance: json['last_maintenance'] != null ? DateTime.parse(json['last_maintenance']) : null,
      companyId: json['company_id'],
      amount: json['amount'],
    );
  }
}












class Market {
  final int id;
  final String? image;
  final String name;
  final String slug;
  final String location;
  final String city;
  final String description;
  final int? permitId;
  final bool status;
  final String startTime;
  final String endTime;
  final bool isOpenMonday;
  final bool isOpenTuesday;
  final bool isOpenWednesday;
  final bool isOpenThursday;
  final bool isOpenFriday;
  final bool isOpenSaturday;
  final bool isOpenSunday;
  final String? notes;
  final int createdBy;
  final int companyId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  Market({
    required this.id,
    this.image,
    required this.name,
    required this.slug,
    required this.location,
    required this.city,
    required this.description,
    this.permitId,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.isOpenMonday,
    required this.isOpenTuesday,
    required this.isOpenWednesday,
    required this.isOpenThursday,
    required this.isOpenFriday,
    required this.isOpenSaturday,
    required this.isOpenSunday,
    this.notes,
    required this.createdBy,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['id'],
      image: json['image'],
      name: json['name'],
      slug: json['slug'],
      location: json['location'],
      city: json['city'],
      description: json['description'],
      permitId: json['permit_id'],
      status: json['status'] == 1,
      startTime: json['start_time'],
      endTime: json['end_time'],
      isOpenMonday: json['is_open_monday'] == 1,
      isOpenTuesday: json['is_open_tuesday'] == 1,
      isOpenWednesday: json['is_open_wednesday'] == 1,
      isOpenThursday: json['is_open_thursday'] == 1,
      isOpenFriday: json['is_open_friday'] == 1,
      isOpenSaturday: json['is_open_saturday'] == 1,
      isOpenSunday: json['is_open_sunday'] == 1,
      notes: json['notes'],
      createdBy: json['created_by'],
      companyId: json['company_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }
}

class Vehicle {
  final int id;
  final String make;
  final String model;
  final int year;
  final String color;
  final int mileage;
  final String? image;
  final String location;
  final bool status;
  final String slug;
  final String registrationNumber;
  final String registrationExpiry;
  final String insuranceProvider;
  final String insuranceExpiry;
  final String type;
  final int capacity;
  final String condition;
  final int companyId;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.mileage,
    this.image,
    required this.location,
    required this.status,
    required this.slug,
    required this.registrationNumber,
    required this.registrationExpiry,
    required this.insuranceProvider,
    required this.insuranceExpiry,
    required this.type,
    required this.capacity,
    required this.condition,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      make: json['make'],
      model: json['v_model'],
      year: json['year'],
      color: json['color'],
      mileage: json['mileage'],
      image: json['image'],
      location: json['location'],
      status: json['status'] == 1,
      slug: json['slug'],
      registrationNumber: json['registration_number'],
      registrationExpiry: json['registration_expiry'],
      insuranceProvider: json['insurance_provider'],
      insuranceExpiry: json['insurance_expiry'],
      type: json['type'],
      capacity: json['capacity'],
      condition: json['condition'],
      companyId: json['company_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      deletedAt: json['deleted_at'],
    );
  }

}
