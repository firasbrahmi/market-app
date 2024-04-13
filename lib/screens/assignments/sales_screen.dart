import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/Sales.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../providers/userProvider.dart';
import '../assignments/menu_screen.dart';

class SalesScreen extends StatefulWidget {
  static String routeName = "/sales";
  final String companySlug;
  final String assignmentSlug;

  SalesScreen({
    required this.companySlug,
    required this.assignmentSlug,
  });

  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  late Future<Sales> salesFuture;

  @override
  void initState() {
    super.initState();
    salesFuture = _fetchSales();
  }

  Future<void> _refresh() async {
    setState(() {
      salesFuture = _fetchSales();
    });
  }

  Future<Sales> _fetchSales() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.user?.accessToken;
    if (accessToken == null) {
      throw Exception("Access token is null");
    }
    return userProvider.fetchSales(
      accessToken,
      widget.companySlug,
      widget.assignmentSlug,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales for ${widget.companySlug} - ${widget.assignmentSlug}'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Sales>(
          future: salesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _errorDisplay(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.sales.isEmpty) {
              return _emptySalesDisplay();
            } else {
              return _salesListDisplay(snapshot.data!.sales);
            }
          },
        ),
      ),
    );
  }

  Widget _errorDisplay(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Error: $error'),
          ElevatedButton(
            onPressed: _refresh,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _emptySalesDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('No sales data available.'),
ElevatedButton(
onPressed: _refresh,
child: Text('Refresh'),
),
],
),
);
}

Widget _salesListDisplay(List<Sale> sales) {
return Column(
children: <Widget>[
AssignmentMenu(
companySlug: widget.companySlug,
assignmentSlug: widget.assignmentSlug,
),
SizedBox(height: 10),
Expanded(
child: ListView.builder(
itemCount: sales.length,
itemBuilder: (ctx, index) {
final sale = sales[index];
return Card(
elevation: 5,
margin: EdgeInsets.all(10),
child: ExpansionTile(
title: Text('Sale on ${timeago.format(sale.time, locale: 'en')}'),
subtitle: Text('Total: ${sale.total}'),
children: <Widget>[
Padding(
padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: <Widget>[
Text('Custom Total: ${sale.customTotal}'),
Text('Discount: ${sale.discount ?? 'N/A'}'),
Text('Method: ${sale.method}'),
Divider(),
Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
...sale.products.map((product) => Text(
'${product.product_name} - Quantity: ${product.quantity}',
)).toList(),
],
),
),
],
),
);
},
),
),
],
);
}
}