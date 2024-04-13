class Reports {
  final Report? report;
  final Map<String, List<CategoryProduct>>? categoryProducts;

  Reports({this.report, this.categoryProducts});

  factory Reports.fromJson(Map<String, dynamic> json) {
    return Reports(
      report: json['report'] != null ? Report.fromJson(json['report']) : null,
      categoryProducts: json['categoryProducts']
!= null
? _parseCategoryProducts(json['categoryProducts'])
: null,
);
}

static Map<String, List<CategoryProduct>> _parseCategoryProducts(
Map<String, dynamic> json) {
return json.map((key, value) => MapEntry(
key, (value as List).map((e) => CategoryProduct.fromJson(e)).toList()));
}
}

class CategoryProduct {
final int quantity;
final String price;
final int sold;
final int extra;
final int missing;
final Product product;

CategoryProduct({
required this.quantity,
required this.price,
required this.sold,
required this.extra,
required this.missing,
required this.product,
});

factory CategoryProduct.fromJson(Map<String, dynamic> json) {
return CategoryProduct(
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

Product({required this.id, required this.name, this.image});

factory Product.fromJson(Map<String, dynamic> json) {
return Product(
id: json['id'],
name: json['name'],
image: json['image'],
);
}
}

class Report {
final int id;
final int assignmentId;
final int vendorId;
final int marketId;
final String total;
final String marketFee;
final String cash;
final String card;
final String ebt;
final String marketFeedback;
final int companyId;
final String createdAt;
final String updatedAt;
final List<ProductReport> productsReports;

Report({
required this.id,
required this.assignmentId,
required this.vendorId,
required this.marketId,
required this.total,
required this.marketFee,
required this.cash,
required this.card,
required this.ebt,
required this.marketFeedback,
required this.companyId,
required this.createdAt,
required this.updatedAt,
required this.productsReports,
});

factory Report.fromJson(Map<String, dynamic> json) {
var productsReportsList = json['products_reports'] as List;
List<ProductReport> productsReports = productsReportsList.map((i) => ProductReport.fromJson(i)).toList();
return Report(
  id: json['id'],
  assignmentId: json['assignment_id'],
  vendorId: json['vendor_id'],
  marketId: json['market_id'],
  total: json['total'],
  marketFee: json['market_fee'],
  cash: json['cash'],
  card: json['card'],
  ebt: json['ebt'],
  marketFeedback: json['market_feedback'],
  companyId: json['company_id'],
  createdAt: json['created_at'],
  updatedAt: json['updated_at'],
  productsReports: productsReports,
);
}
}

class ProductReport {
final int id;
final int reportId;
final int assignmentId;
final int productId;
final int assigned;
final String price;
final int sold;
final int leftover;
final int missing;
final int extra;
final int companyId;
final String createdAt;
final String updatedAt;
final Product product;

ProductReport({
required this.id,
required this.reportId,
required this.assignmentId,
required this.productId,
required this.assigned,
required this.price,
required this.sold,
required this.leftover,
required this.missing,
required this.extra,
required this.companyId,
required this.createdAt,
required this.updatedAt,
required this.product,
});

factory ProductReport.fromJson(Map<String, dynamic> json) {
return ProductReport(
id: json['id'],
reportId: json['report_id'],
assignmentId: json['assignment_id'],
productId: json['product_id'],
assigned: json['assigned'],
price: json['price'],
sold: json['sold'],
leftover: json['leftover'],
missing: json['missing'],
extra: json['extra'],
companyId: json['company_id'],
createdAt: json['created_at'],
updatedAt: json['updated_at'],
product: Product.fromJson(json['product']),
);
}
}