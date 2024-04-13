class Sales {
  List<Sale> sales; // Add a 'sales' property to store a list of sales

  Sales({
    required this.sales,
  });

  factory Sales.fromJson(Map<String, dynamic> json) {
    List<Sale> salesData = [];
    if (json['sales'] != null) {
      salesData = (json['sales'] as List)
          .map((saleJson) => Sale.fromJson(saleJson))
          .toList();
    }

    return Sales(
      sales: salesData, // Assign the 'sales' list
    );
  }
}

class Sale {
  String assignmentSlug;
  String marketSlug;
  DateTime time;
  String total;
  String customTotal;
  String? discount;
  String method;
  List<Product> products;

  Sale({
    required this.assignmentSlug,
    required this.marketSlug,
    required this.time,
    required this.total,
    required this.customTotal,
    this.discount,
    required this.method,
    required this.products,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    List<Product> productData = [];
    if (json['products'] != null) {
      productData = (json['products'] as List)
          .map((productJson) => Product.fromJson(productJson))
          .toList();
    }

    return Sale(
      assignmentSlug: json['assignment_slug'],
      marketSlug: json['market_slug'],
      time: DateTime.parse(json['time']), // Parse the timestamp as DateTime
      total: json['total'] ?? '0.00',
      customTotal: json['custom_total'] ?? '0.00',
      discount: json['discount'] ?? '0.00',
      method: json['method'],
      products: productData,
    );
  }
}

class Product {
  String product_name;
  int quantity;

  Product({
    required this.product_name,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      product_name: json['product_name'],
      quantity: json['quantity'],
    );
  }
}
