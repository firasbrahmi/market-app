import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/userProvider.dart';
import '../../models/Report.dart';
import '../assignments/menu_screen.dart';

class ReportsScreen extends StatefulWidget {
  static String routeName = "/reports";
  final String companySlug;
  final String assignmentSlug;

  ReportsScreen({
    required this.companySlug,
    required this.assignmentSlug,
  });

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<Reports> reportFuture;
  // Maps to hold the controllers for each product
  Map<int, TextEditingController> missingControllers = {};
  Map<int, TextEditingController> extraControllers = {};
  Map<int, TextEditingController> leftoverControllers = {};

  // Controllers for totals
  final TextEditingController cashController = TextEditingController(text: '0');
  final TextEditingController cardController = TextEditingController(text: '0');
  final TextEditingController ebtController = TextEditingController(text: '0');
  final TextEditingController totalController = TextEditingController(text: '0');
  final TextEditingController marketFeeController = TextEditingController(text: '0');
  final TextEditingController marketFeedbackController = TextEditingController();
  bool isInformationChecked = false;

  @override
  void initState() {
    super.initState();
    reportFuture = _fetchReport();

    // Add listeners to the totalController
    totalController.addListener(() {
      // Set a flag to indicate that the user is manually editing the total field
      isUserEditingTotal = true;
    });
  }

  @override
  void dispose() {
    // Remove listeners from the totalController
    totalController.removeListener(() {
      // Reset the flag when the widget is disposed
      isUserEditingTotal = false;
    });

    // Dispose of your controllers here
    missingControllers.forEach((key, controller) => controller.dispose());
    extraControllers.forEach((key, controller) => controller.dispose());
    leftoverControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _refreshAssignment() async {
    setState(() {
      reportFuture = _fetchReport();
    });
  }

  Future<Reports> _fetchReport() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.user?.accessToken;
    if (accessToken == null) {
      throw Exception("Access token is null");
    }
    return userProvider.fetchReport(
      accessToken,
      widget.companySlug,
      widget.assignmentSlug,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          key: _scaffoldKey, // Add this line

      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAssignment,
        child: FutureBuilder<Reports>(
          future: reportFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final reportData = snapshot.data!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (reportData.report != null) ...[
                        _buildReportDetailSection(reportData.report!),
                        const SizedBox(height: 20),
                        _buildProductsReportTable(reportData.report!),
                      ] else if (reportData.categoryProducts != null) ...[
                        _buildCategoryProductsSection(reportData.categoryProducts!),
                        const SizedBox(height: 20),
                        _buildTotalCalculationSection(),
                        const SizedBox(height: 20),
                        _buildConfirmationSection(),
                        _buildSubmitButton(),
                      ],
                    ],
                  ),
                ),
              );
            } else {
              return const Text('No data available');
            }
          },
        ),
      ),
    );
  }

Widget _buildReportDetailSection(Report report) {
  // This widget displays the report details that are not editable
  return Card(
    elevation: 4.0,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Report - #${report.id}', style: Theme.of(context).textTheme.headline6),
          Text('Date: ${report.createdAt}'),
          Text('Total: ${report.total}'),
          Text('Cash: ${report.cash}'),
          Text('Card: ${report.card}'),
          Text('EBT: ${report.ebt}'),
          Text('Market Fee: ${report.marketFee}'),
          Text('Market Feedback: ${report.marketFeedback}'),
        ],
      ),
    ),
  );
}


Widget _buildProductsReportTable(Report report) {
  // This widget displays the products report in a table format.
  List<DataRow> productRows = report.productsReports.map((productReport) {
    return DataRow(
      cells: <DataCell>[
        DataCell(Text(productReport.product.name)), // Ensure this is a String
        DataCell(Text(productReport.assigned.toString())), // Convert integer to String
        DataCell(Text(productReport.sold.toString())), // Convert integer to String
        DataCell(Text(productReport.missing.toString())), // Convert integer to String
        DataCell(Text(productReport.extra.toString())), // Convert integer to String
        DataCell(Text(productReport.leftover.toString())), // Convert integer to String
      ],
    );
  }).toList();

  return DataTable(
    columns: const <DataColumn>[
      DataColumn(label: Text('Product')),
      DataColumn(label: Text('Assigned')),
      DataColumn(label: Text('Sold')),
      DataColumn(label: Text('Missing')),
      DataColumn(label: Text('Extra')),
      DataColumn(label: Text('Leftover')),
    ],
    rows: productRows,
  );
}


  Widget _buildCategoryProductsSection(Map<String, List<CategoryProduct>> categoryProducts) {
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: categoryProducts.entries.map((entry) {
        String category = entry.key;
        List<CategoryProduct> products = entry.value;

        return Card(
          elevation: 2.0,
          margin: EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            children: products.map((product) {
              // Initialize controllers for each product
              missingControllers[product.product.id] = TextEditingController(text: product.missing.toString());
              extraControllers[product.product.id] = TextEditingController(text: product.extra.toString());
              leftoverControllers[product.product.id] = TextEditingController(text: (product.quantity + product.extra - product.missing - product.sold).toString());

              return Column(
                children: [
                  ListTile(
                    title: Text(product.product.name),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Assigned: ${product.quantity}'),
                      SizedBox(width: 8.0),
                      Text('Sold: ${product.sold}'),
                      SizedBox(width: 8.0),
                      _editableField('Missing', missingControllers[product.product.id]),
                      SizedBox(width: 8.0),
                      _editableField('Extra', extraControllers[product.product.id]),
                      SizedBox(width: 8.0),
                      _editableField('Leftover', leftoverControllers[product.product.id]), // Leftover is now editable
                    ],
                  ),
                ],
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

Widget _editableField(String label, TextEditingController? controller, {bool isEditable = true}) {
  return Expanded(
    child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      enabled: isEditable,
      // Removed the onChanged logic to disable automatic calculation
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'Please enter a number';
  } else if (int.tryParse(value) != null && int.parse(value) < 0) {
    return 'Please enter a positive number';
  }
  return null;
},

),
);
}

bool isUserEditingTotal = false;

Widget _buildTotalCalculationSection() {
  // Controllers for total calculation fields
  return Column(
    children: [
      TextFormField(
        controller: cashController,
        decoration: const InputDecoration(labelText: 'Cash'),
        keyboardType: TextInputType.number,
        onChanged: (_) => _updateTotal(),
        // Add listeners and validation
      ),
      TextFormField(
        controller: cardController,
        decoration: const InputDecoration(labelText: 'Card'),
        keyboardType: TextInputType.number,
        onChanged: (_) => _updateTotal(),
        // Add listeners and validation
      ),
      TextFormField(
        controller: ebtController,
        decoration: const InputDecoration(labelText: 'EBT'),
        keyboardType: TextInputType.number,
        onChanged: (_) => _updateTotal(),
        // Add listeners and validation
      ),
      TextFormField(
        controller: totalController,
        decoration: const InputDecoration(labelText: 'Total'),
        keyboardType: TextInputType.number,
        onChanged: (_) => isUserEditingTotal = true, // Set the flag when the user edits total
        // Add listeners and validation
      ),
      TextFormField(
        controller: marketFeeController,
        decoration: const InputDecoration(labelText: 'Market Fee'),
        keyboardType: TextInputType.number,
        // Add listeners and validation
      ),
      TextFormField(
        controller: marketFeedbackController,
        decoration: const InputDecoration(labelText: 'Market Feedback'),
        // Add listeners and validation
      ),
    ],
  );
}

void _updateTotal() {
  if (!isUserEditingTotal) {
    // Calculate the total based on the values in cash, card, and EBT fields
    double cash = double.tryParse(cashController.text) ?? 0.0;
    double card = double.tryParse(cardController.text) ?? 0.0;
    double ebt = double.tryParse(ebtController.text) ?? 0.0;

    double total = cash + card + ebt;

    // Update the totalController with the calculated total
    // Set the flag to prevent recursive calling of _updateTotal
    isUserEditingTotal = true;
    totalController.text = total.toStringAsFixed(2); // Format as a fixed decimal with 2 digits
    isUserEditingTotal = false; // Reset the flag after updating
  }
}



Widget _buildConfirmationSection() {
  return CheckboxListTile(
    title: const Text("I have checked the information and it is correct"),
    value: isInformationChecked,
    onChanged: (newValue) {
      setState(() {
        isInformationChecked = newValue ?? false;
      });
    },
    controlAffinity: ListTileControlAffinity.leading,  // Or use trailing based on the design
  );
}


Widget _buildSubmitButton() {
  return ElevatedButton(
    onPressed: () {
      // Make sure to validate all fields before attempting to submit
      if (_validateReportForm()) {
        _submitReport();
      }
    },
    child: const Text('Complete Assignment'),
  );
}

bool _validateReportForm() {
  // Check if all text fields are filled, and the checkbox is checked
  if (totalController.text.isEmpty ||
      cashController.text.isEmpty ||
      cardController.text.isEmpty ||
      ebtController.text.isEmpty ||
      marketFeeController.text.isEmpty ||
      marketFeedbackController.text.isEmpty) {
    // Show an error message for the required fields
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All fields are required'),
      ),
    );
    return false;
  }

  return isInformationChecked; // Example validation check
}

void _submitReport() async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final accessToken = userProvider.user?.accessToken;
  if (accessToken == null) {
    print('Access token is null');
    return;
  }

  // Prepare the data for submission
  Map<String, dynamic> reportData = {
    'total': totalController.text,
    'cash': cashController.text,
    'card': cardController.text,
    'ebt': ebtController.text,
    'market_fee': marketFeeController.text,
    'market_feedback': marketFeedbackController.text,
    'id': [], // Product IDs
    'assigned': [], // Assigned values
    'price': [], // Prices
    'sold': [], // Sold values
    'leftover': [], // Leftover values
    'missing': [], // Missing values
    'extra': [], // Extra values
  };

  final Reports? currentReport = await reportFuture;
  if (currentReport != null && currentReport.categoryProducts != null) {
    currentReport.categoryProducts!.forEach((category, products) {
      for (var product in products) {
        reportData['id'].add(product.product.id);
        reportData['assigned'].add(product.quantity);
        reportData['price'].add(product.price);
        reportData['sold'].add(product.sold);

        // Get the values from controllers, ensuring they are not empty
        String leftoverValue = leftoverControllers[product.product.id]?.text ?? '';
        String missingValue = missingControllers[product.product.id]?.text ?? '';
        String extraValue = extraControllers[product.product.id]?.text ?? '';

        // Add the values to the reportData map
        reportData['leftover'].add(leftoverValue);
        reportData['missing'].add(missingValue);
        reportData['extra'].add(extraValue);
      }
    });
  } else {
    print('Products data is missing');
    return;
  }

  // Submit the report
  try {
    await userProvider.submitReport(
      accessToken,
      widget.companySlug,
      widget.assignmentSlug,
      reportData,
    );
    print('Report submitted successfully');
    
    // Show a success message using a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report submitted successfully'),
      ),
    );
    
    // Refresh the page after submission
    _refreshAssignment();
  } catch (e) {
    print('Failed to submit report: $e');
  }
}


}
