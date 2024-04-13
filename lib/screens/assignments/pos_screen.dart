import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/Pos.dart';
import '../../../providers/userProvider.dart';
import 'package:square_in_app_payments/in_app_payments.dart';
import 'package:square_in_app_payments/models.dart' as square_payments;
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'dart:convert';

// Define a PaymentMethod enum
enum PaymentMethod { Cash, Square, Stripe }

// Define a ChangeNotifier class for managing order state
class OrderProvider extends ChangeNotifier {
  Map<Product, int> _currentOrder = {};
  Map<Product, int> get currentOrder => _currentOrder;
  PaymentMethod selectedPaymentMethod = PaymentMethod.Cash; // Default to Cash

  void addToOrder(Product product) {
    if (_currentOrder.containsKey(product)) {
      _currentOrder[product] = _currentOrder[product]! + 1;
    } else {
      _currentOrder[product] = 1;
    }
    notifyListeners();
  }

  void removeFromOrder(Product product) {
    if (_currentOrder.containsKey(product) && _currentOrder[product]! > 1) {
      _currentOrder[product] = _currentOrder[product]! - 1;
    } else {
      _currentOrder.remove(product);
    }
    notifyListeners();
  }

  void clearCurrentOrder() {
    _currentOrder.clear();
    notifyListeners();
  }
}

class PosScreen extends StatefulWidget {
  static String routeName = "/pos";
  final String companySlug;
  final String assignmentSlug;

  PosScreen({
    required this.companySlug,
    required this.assignmentSlug,
  });

  @override
  _PosScreenState createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  late Future<Pos> posFuture;
  double discount = 0.0;
  List<Product>? selectedCategoryProducts; // Add this line
  PaymentMethod selectedPaymentMethod = PaymentMethod.Cash; // Add this line
  late Company company; // Add this line to hold the company data
  String paymentNonce = '';
  late int assignmentId;
  late int marketId;
  late List<int> productIds;
  late List<int> quantities;
  late double total;

  @override
  void initState() {
    super.initState();
    posFuture = _fetchPos();
  }

  Future<void> _refresh() async {
    setState(() {
      posFuture = _fetchPos();
    });
  }

  Future<Pos> _fetchPos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.user?.accessToken;
    if (accessToken == null) {
      throw Exception("Access token is null");
    }
    final pos = await userProvider.fetchPos(
      accessToken,
      widget.companySlug,
      widget.assignmentSlug,
    );

    // Set the company variable with the company data
    setState(() {
      company = pos.company;
    });

    return pos;
  }

  void _pay(Company company) {
    if (selectedPaymentMethod == PaymentMethod.Square) {
      InAppPayments.setSquareApplicationId(company.squareApplicationId);
      InAppPayments.startCardEntryFlow(
        onCardEntryCancel: _cardEntryCancel,
        onCardNonceRequestSuccess: _cardNonceRequestSuccess,
      );
    } else if (selectedPaymentMethod == PaymentMethod.Stripe) {
      _payWithStripe(company.name, company.stripeKey);
    } else if (selectedPaymentMethod == PaymentMethod.Cash) {
      _payWithCash();
    }
  }

  void _payWithStripe(String companyName, String stripeKey) async {
    stripe.Stripe.publishableKey = stripeKey; // Replace with your publishable key
    UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    final String apiUrl = 'https://themarketmanager.com/api/company/${widget.companySlug}/assignment/${widget.assignmentSlug}/stripe/intent';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${userProvider.user?.accessToken}',
        },
        body: jsonEncode({'amount': (total * 100).toInt()}),
      );
      final responseData = json.decode(response.body);
      final clientSecret = responseData['clientSecret'];

      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: companyName,
        ),
      );

      await stripe.Stripe.instance.presentPaymentSheet();

      try {
        // Prepare the data to send to the server
        Map<String, dynamic> saleData = {
          'assignment_id': assignmentId,
          'market_id': marketId,
          'id': productIds,
          'quantity': quantities,
          'total': total.toString(),
          'discount': discount.toString(),
          'method': 'stripeApi',
        };

        // Call the UserProvider to submit the sale data to your server
        UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
        var saleResponse = await userProvider.submitSale(
          userProvider.user?.accessToken ?? '',
          widget.companySlug,
          widget.assignmentSlug,
          saleData,
        );

        if (saleResponse.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(saleResponse.message))
          );

          _refresh(); // Refresh the page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(saleResponse.message))
          );
        }

        // Handle the server response
        // For example, show a success message or navigate to a confirmation screen
        // You might also want to update the UI based on the response
      } catch (e) {
        // Handle any errors that occur during the payment process
        // You can show an error message or take other appropriate actions
        print('Error processing Square payment: ');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Failed:")));
    }
  }

  void _cardEntryCancel() {
    // Handle cancellation
  }

  void _cardNonceRequestSuccess(square_payments.CardDetails result) {
    paymentNonce = result.nonce;
    InAppPayments.completeCardEntry(onCardEntryComplete: _cardEntryComplete);
  }

  void _cardEntryComplete() async {
    try {
      // Prepare the data to send to the server
      Map<String, dynamic> saleData = {
        'assignment_id': assignmentId,
        'market_id': marketId,
        'id': productIds,
        'quantity': quantities,
        'total': total.toString(),
        'discount': discount.toString(),
        'method': 'square',
        'token': paymentNonce, // Square payment nonce
      };

      // Call the UserProvider to submit the sale data to your server
      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      var saleResponse = await userProvider.submitSale(
        userProvider.user?.accessToken ?? '',
        widget.companySlug,
        widget.assignmentSlug,
        saleData,
      );

      if (saleResponse.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(saleResponse.message))
        );

        _refresh(); // Refresh the page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(saleResponse.message))
        );
      }

      // Handle the server response
      // For example, show a success message or navigate to a confirmation screen
      // You might also want to update the UI based on the response
    } catch (e) {
      // Handle any errors that occur during the payment process
      // You can show an error message or take other appropriate actions
      print('Error processing Square payment: ');
    }
  }

  void _payWithCash() async {
    try {
      // Prepare the data to send to the server
      Map<String, dynamic> saleData = {
        'assignment_id': assignmentId,
        'market_id': marketId,
        'id': productIds,
        'quantity': quantities,
        'total': total.toString(),
        'discount': discount.toString(),
        'method': 'cash',
      };

      // Call the UserProvider to submit the sale data to your server
      UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
      var saleResponse = await userProvider.submitSale(
        userProvider.user?.accessToken ?? '',
        widget.companySlug,
        widget.assignmentSlug,
        saleData,
      );

      if (saleResponse.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(saleResponse.message))
        );
        
        _refresh(); // Refresh the page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(saleResponse.message))
        );
      }
    } catch (e) {
      print('Error processing Square payment: ');
    }
  }

  @override
Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (context) => OrderProvider(),
    child: Scaffold(
      appBar: AppBar(
        title: Text('Point Of Sale'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () =>
                Provider.of<OrderProvider>(context, listen: false)
                    .clearCurrentOrder(),
            tooltip: 'Clear Order',
          ),
        ],
      ),
      body: FutureBuilder<Pos>(
        future: posFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available.'));
          }

          final posData = snapshot.data!;

          // Use Consumer<OrderProvider> to build parts of the UI that depend on the order state
          return Consumer<OrderProvider>(
            builder: (context, orderProvider, child) {
              return Column(
                children: [
                  // Categories Section (horizontal list)
                  Container(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: posData.categories.length,
                      itemBuilder: (context, index) {
                        final category =
                            posData.categories.values.toList()[index];
                        final categoryImageUrl = category.image != null
                            ? 'https://themarketmanager.com/${category.image}'
                            : 'https://themarketmanager.com/assets/media/image.png';
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedCategoryProducts = category.products;
                            });
                          },
                          child: Container(
                            width: 100,
                            child: Card(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.network(
                                    categoryImageUrl,
                                    width: 50,
                                    height: 50,
                                  ),
                                  Text(category.name),
                                  Text('${category.products.length} products'),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Products List Section
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedCategoryProducts?.length ??
                          posData.categories.values.first.products.length,
                      itemBuilder: (context, index) {
                        final product = selectedCategoryProducts != null
                            ? selectedCategoryProducts![index]
                            : posData.categories.values.first.products[index];
                        final productImageUrl = product.image != null
                            ? 'https://themarketmanager.com/${product.image}'
                            : 'https://themarketmanager.com/assets/media/image.png';
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: ListTile(
                            title: Text(product.name),
                            subtitle: Text('\$${product.price}'),
                            leading: Image.network(
                              productImageUrl,
                              width: 50,
                              height: 50,
                            ),
                            trailing: Text(
                                '${product.assigned + product.extra - product.sold - product.missing} In Stock'),
                            onTap: () => orderProvider.addToOrder(product),
                          ),
                        );
                      },
                    ),
                  ),

                  // Current Order Section
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderProvider.currentOrder.length,
                      itemBuilder: (context, index) {
                        Product product =
                            orderProvider.currentOrder.keys.elementAt(index);
                        int quantity = orderProvider.currentOrder[product]!;

                        // Calculate remaining stock
                        int remainingStock = product.assigned +
                            product.extra -
                            product.sold -
                            product.missing -
                            (quantity);

                        return ListTile(
                          title: Text(product.name),
                          // Modify the subtitle property with conditional text color change
                          subtitle: Text(
                            '\$${product.price} x $quantity',
                            style: TextStyle(
                              color: remainingStock >= 0
                                  ? Colors.black
                                  : Colors
                                      .red, // Set color to red if stock is negative
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Ensure the row takes the minimum space needed
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: () =>
                                    orderProvider.removeFromOrder(product),
                              ),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: () =>
                                    orderProvider.addToOrder(
                                        product), // Add logic to increase quantity
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Subtotal, Discounts, and Total Section
                  Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Subtotal'),
                              Text(
                                  '\$${(orderProvider.currentOrder.entries.fold(0.0, (total, entry) => total + (double.tryParse(entry.key.price) ?? 0.0) * entry.value)).toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Discount'),
                              SizedBox(
                                width: 100, // Adjust the width as needed
                                child: TextField(
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: 8), // Reduced padding
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          5.0), // Rounded corners
                                    ),
                                    isDense:
                                        true, // Reduces the height of the input field
                                  ),
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(
                                      fontSize: 14), // Smaller font size
                                  onChanged: (value) {
                                    setState(() {
                                      discount = double.tryParse(value) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                              Text('-\$${discount.toStringAsFixed(2)}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Total'),
                              Text(
                                  '\$${(orderProvider.currentOrder.entries.fold(0.0, (total, entry) => total + (double.tryParse(entry.key.price) ?? 0.0) * entry.value) - discount).toStringAsFixed(2)}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Payment Method Section
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedPaymentMethod = PaymentMethod
                                  .Cash; // Set selected payment method to Cash
                            });
                            // Implement payment logic for Cash
                          },
                          style: ElevatedButton.styleFrom(
                            primary: selectedPaymentMethod ==
                                    PaymentMethod.Cash
                                ? Colors.green
                                : null, // Set green color for selected method
                          ),
                          child: Text(
                            'Cash',
                            style: TextStyle(
                              color: selectedPaymentMethod ==
                                      PaymentMethod.Cash
                                  ? Colors.white
                                  : null, // Set white text color for selected method
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedPaymentMethod = PaymentMethod
                                  .Square; // Set selected payment method to Square
                            });
                            // Implement payment logic for Stripe
                          },
                          style: ElevatedButton.styleFrom(
                            primary: selectedPaymentMethod ==
                                    PaymentMethod.Square
                                ? Colors.green
                                : null, // Set green color for selected method
                          ),
                          child: Text(
                            'Square',
                            style: TextStyle(
                              color: selectedPaymentMethod ==
                                      PaymentMethod.Square
                                  ? Colors.white
                                  : null, // Set white text color for selected method
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedPaymentMethod = PaymentMethod
                                  .Stripe; // Set selected payment method to Stripe
                            });
                            // Implement payment logic for Stripe
                          },
                          style: ElevatedButton.styleFrom(
                            primary: selectedPaymentMethod ==
                                    PaymentMethod.Stripe
                                ? Colors.green
                                : null, // Set green color for selected method
                          ),
                          child: Text(
                            'Stripe',
                            style: TextStyle(
                              color: selectedPaymentMethod ==
                                      PaymentMethod.Stripe
                                  ? Colors.white
                                  : null, // Set white text color for selected method
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Checkout Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: double
                          .infinity, // makes the button stretch to fill the width
                      child: ElevatedButton(
                        onPressed: () async {
                          // Set the member variables here
                          assignmentId = orderProvider
                              .currentOrder.keys.first.assignmentId;
                          marketId =
                              orderProvider.currentOrder.keys.first.marketId;
                          productIds = orderProvider.currentOrder.keys
                              .map((product) => product.productId)
                              .toList();
                          quantities =
                              orderProvider.currentOrder.values.toList();
                          total = orderProvider.currentOrder.entries.fold(
                                  0.0,
                                  (total, entry) =>
                                      total +
                                      (double.tryParse(entry.key.price) ??
                                              0.0) *
                                          entry.value) -
                              discount;

                          // Check if the selected payment method is Square
                          _pay(company);
                        },
                        child: Text('Checkout'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    ),
  );
}
}