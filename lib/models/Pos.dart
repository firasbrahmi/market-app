class Pos {
  final Company company; // Add a Company object field
  final Map<String, Category> categories;

  Pos({
    required this.company, // Initialize the Company object
    required this.categories,
  });

factory Pos.fromJson(Map<String, dynamic> json) {
  Map<String, dynamic> categoriesData = json['categories'];
  Map<String, Category> categoriesMap = {};

  categoriesData.forEach((key, value) {
    categoriesMap[key] = Category.fromJson(value);
  });

  Map<String, dynamic> companyData = json['company'];
  Company company = Company.fromJson(companyData);

  return Pos(
    company: company,
    categories: categoriesMap,
  );
}

}

class Category {
  final int id;
  final String name;
  final String? image;
  final List<Product> products;

  Category({
    required this.id,
    required this.name,
    this.image,
    required this.products,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    List<dynamic> productsData = json['products'];
    List<Product> productList = [];

    productsData.forEach((productData) {
      productList.add(Product.fromJson(productData));
    });

    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      products: productList,
    );
  }
}

class Product {
  final int marketId;
  final int assignmentId;
  final int assignedProductId;
  final String name;
  final String price;
  final int assigned;
  final int sold;
  final int extra;
  final int missing;
  final String? image;
  final int productId;

  Product({
    required this.marketId,
    required this.assignmentId,
    required this.assignedProductId,
    required this.name,
    required this.price,
    required this.assigned,
    required this.sold,
    required this.extra,
    required this.missing,
    this.image,
    required this.productId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      marketId: json['market_id'],
      assignmentId: json['assignment_id'],
      assignedProductId: json['assigned_product_id'],
      name: json['name'],
      price: json['price'],
      assigned: json['assigned'],
      sold: json['sold'],
      extra: json['extra'],
      missing: json['missing'],
      image: json['image'],
      productId: json['product_id'],
    );
  }
}



class Company {
  String name;

  bool cashStatus;
  bool squareStatus;
  bool stripeStatus;

  String squareEnvironment;
  String squareApplicationId;
  String squareAccessToken;
  String squareLocationId;
  
  String stripeKey;
  String stripeSecret;

  Company({
      required this.name,

      required this.cashStatus,
      required this.squareStatus,
      required this.stripeStatus,
      
      required this.squareEnvironment,
      required this.squareApplicationId,
      required this.squareAccessToken,
      required this.squareLocationId,
      
      required this.stripeKey,
      required this.stripeSecret,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
        name: json['name'],

        cashStatus: json['CASH_STATUS'] == 1,
        squareStatus: json['SQUARE_STATUS'] == 1,
        stripeStatus: json['STRIPE_STATUS'] == 1,

        squareEnvironment: json['SQUARE_ENVIRONMENT'],
        squareApplicationId: json['SQUARE_APPLICATION_ID'],
        squareAccessToken: json['SQUARE_ACCESS_TOKEN'],
        squareLocationId: json['SQUARE_LOCATION_ID'],

        stripeKey: json['STRIPE_KEY'],
        stripeSecret: json['STRIPE_SECRET'],
    );
  }
}