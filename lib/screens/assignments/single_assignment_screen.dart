import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/userProvider.dart';
import '../../models/AssignmentDetail.dart';
import '../assignments/menu_screen.dart';

class SingleAssignmentScreen extends StatefulWidget {
  static String routeName = "/assignment";
  final String companySlug;
  final String assignmentSlug;

  SingleAssignmentScreen({
    required this.companySlug,
    required this.assignmentSlug,
  });

  @override
  _SingleAssignmentScreenState createState() => _SingleAssignmentScreenState();
}

class _SingleAssignmentScreenState extends State<SingleAssignmentScreen> {
  late Future<AssignmentDetail> assignmentDetailFuture;
  String appBarTitle = 'Assignment Details';

  @override
  void initState() {
    super.initState();
    assignmentDetailFuture = _fetchAssignmentDetails();
  }

  Future<void> _refreshAssignment() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      assignmentDetailFuture = _fetchAssignmentDetails();
    });
  }

  Future<AssignmentDetail> _fetchAssignmentDetails() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final accessToken = userProvider.user?.accessToken;
    if (accessToken == null) {
      throw Exception("Access token is null");
    }
    final assignmentDetail = await userProvider.fetchAssignmentDetails(
      accessToken,
      widget.companySlug,
      widget.assignmentSlug,
    );
    return assignmentDetail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: RefreshIndicator(
          backgroundColor: Colors.white,
          color: Colors.black,
          onRefresh: _refreshAssignment,
          child: FutureBuilder<AssignmentDetail>(
            future: assignmentDetailFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return _buildAssignmentDetails(snapshot.data!);
              } else {
                return Center(child: Text('No assignment details available.'));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentDetails(AssignmentDetail assignment) {
    // Use a ListView.builder for better performance with large lists
    return ListView.builder(
      itemCount: 1, // replace with your actual item count
      itemBuilder: (context, index) {
        // Replace with your actual data
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeaderSection(assignment),
            AssignmentMenu(companySlug: widget.companySlug,assignmentSlug: widget.assignmentSlug,),
            _buildVehicleSection(assignment),
            _buildListSection(assignment),
          ],
        );
      },
    );
  }


Widget _buildHeaderSection(AssignmentDetail assignment) {
  String marketImageUrl = assignment.market.image != null
      ? 'https://themarketmanager.com/${assignment.market.image}'
      : 'https://themarketmanager.com/default-market-image.png'; // Default market image

  // Assuming 'status' is a boolean where true = 1 (Available) and false = 0 (Unavailable)
  bool isMarketAvailable = assignment.market.status;
  String availabilityText = isMarketAvailable ? 'Available' : 'Unavailable';
  Color availabilityColor = isMarketAvailable ? Colors.green : Colors.red;

  return Container(
    decoration: BoxDecoration(
      color: Color.fromARGB(255, 27, 27, 27), // Dark card background
      borderRadius: BorderRadius.circular(12.0), // Rounded corners for the card
    ),
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
              decoration: BoxDecoration(
                color: Colors.white, // You can change the background color as desired
                borderRadius: BorderRadius.circular(10.0), // Rounded corners
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0), // Rounded corners for the image
                child: Image.network(
                  marketImageUrl,
                  width: double.infinity, // Adjust the width to fill the container
                  height: double.infinity, // Adjust the height to fill the container
                  fit: BoxFit.cover, // Maintain aspect ratio and cover the container
                ),
              ),
            ),
            SizedBox(width: 16), // Add spacing between the image and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  assignment.market.name,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                ),
                Text(
                  availabilityText,
                  style: TextStyle(color: availabilityColor),
                ),
                SizedBox(height: 8),
                Text(
                  assignment.market.description,
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildTimeSlot('Start Time', assignment.market.startTime ?? 'N/A'),
            _buildTimeSlot('End Time', assignment.market.endTime ?? 'N/A'),
            _buildTimeSlot('City', assignment.market.city),
          ],
        ),
      ],
    ),
  );
}




  Widget _buildTimeSlot(String label, String time) {
    return Column(
      children: <Widget>[
        Text(
          time,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }





Widget _buildVehicleSection(AssignmentDetail assignment) {
  String vehicleImageUrl = assignment.vehicle.image != null
      ? 'https://themarketmanager.com/${assignment.vehicle.image}'
      : 'https://themarketmanager.com/default-vehicle-image.png'; // Default vehicle image

  return Card(
    color: Color.fromARGB(255, 27, 27, 27), // Dark card background
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0), // Rounded corners for the card
    ),
    margin: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Vehicle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
          child: Image.network(
            vehicleImageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            // Assuming you have a fixed height for the image
            height: 200.0,
          ),
        ),

        
Padding(
  padding: EdgeInsets.only(top: 16.0), // Adjust the top padding as needed
  child: Center(
    child: Text(
      '${assignment.vehicle.make} ${assignment.vehicle.model}',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  ),

              SizedBox(height: 8.0),
              Divider(color: Colors.grey),


        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _vehicleDetailColumn(
                    iconData: Icons.palette,
                    label: 'Color',
                    value: assignment.vehicle.color,
                  ),
                  _vehicleDetailColumn(
                    iconData: Icons.pin_drop,
                    label: 'Location',
                    value: assignment.vehicle.location,
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _vehicleDetailColumn(
                    iconData: Icons.av_timer,
                    label: 'Mileage',
                    value: '${assignment.vehicle.mileage} miles',
                  ),
                  _vehicleDetailColumn(
                    iconData: Icons.check_circle_outline,
                    label: 'Status',
                    value: assignment.vehicle.status ? 'Available' : 'Unavailable',
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _vehicleDetailColumn(
                    iconData: Icons.directions_car,
                    label: 'Type',
                    value: assignment.vehicle.type,
                  ),
                  _vehicleDetailColumn(
                    iconData: Icons.build_circle,
                    label: 'Condition',
                    value: assignment.vehicle.condition,
                  ),
                ],
              ),

            ],
          ),
        ),
      ],
    ),
  );
}

Widget _vehicleDetailColumn({required IconData iconData, required String label, required String value}) {
  return Column(
    children: [
      Icon(iconData, color: Colors.white, size: 28.0),
      SizedBox(height: 8.0),
      Text(
        label,
        style: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 4.0),
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
    ],
  );
}



Widget _buildListSection(AssignmentDetail assignment) {
  return Column(
    children: [
      ..._buildEquipmentCards(assignment.equipments),
      ..._buildProductCards(assignment.assignedProducts),
      // ... Add any other lists or cards you need to display
    ],
  );
}


List<Widget> _buildEquipmentCards(List<Equipment> equipments) {
  String cardTitle = 'Equipments';
  return [
    Card(
      color: Color.fromARGB(255, 27, 27, 27),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              cardTitle,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...equipments.map((equipment) {
            String imageUrl = equipment.image != null
              ? 'https://themarketmanager.com/${equipment.image}'
              : 'https://themarketmanager.com/default-product-image.png';

            return Card(
              color: const Color.fromARGB(255, 0, 0, 0),
              margin: EdgeInsets.all(10),
              child: ListTile(
                leading: equipment.image != null
                    ? Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error_outline); // Fallback if the image fails to load
                        },
                      )
                    : Icon(Icons.image, size: 50), // Default icon if no image URL
                title: Text(
                  equipment.name,
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  'Amount: ${equipment.amount}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ),
  ];
}


List<Widget> _buildProductCards(List<AssignedProduct> assignedProducts) {
  String cardTitle = 'Products'; // Title for the products section

  return [
    Card(
      color: Color.fromARGB(255, 35, 35, 35), // Slightly lighter card background for nested card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners for the card
      ),
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              cardTitle, // Use the title here
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...assignedProducts.map((assignedProduct) {
            // Calculate 'In Stock' value
            int inStock = assignedProduct.quantity + assignedProduct.extra -
                assignedProduct.missing - assignedProduct.sold;


      String imageUrl = assignedProduct.product.image != null
          ? 'https://themarketmanager.com/${assignedProduct.product.image}'
          : 'https://themarketmanager.com/default-product-image.png'; // A default image in case the product image is null



            return Card(
              color: Color.fromARGB(255, 0, 0, 0), // Slightly lighter card background for nested card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0), // Rounded corners for the card
              ),
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    assignedProduct.product.image != null
                        ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error_outline); // fallback if the image fails to load
                            },
                          )
                        : Icon(Icons.image, size: 50), // default icon if no image URL
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              assignedProduct.product.name,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.0),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'In Stock: $inStock',
                              style: TextStyle(color: Colors.white70, fontSize: 14.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Sold: ${assignedProduct.sold}',
                          style: TextStyle(color: Colors.redAccent, fontSize: 14.0),
                        ),
                        Text(
                          'Missing: ${assignedProduct.missing}',
                          style: TextStyle(color: Colors.orangeAccent, fontSize: 14.0),
                        ),
                        Text(
                          'Extra: ${assignedProduct.extra}',
                          style: TextStyle(color: Colors.greenAccent, fontSize: 14.0),
                        ),
                        Text(
                          'Price: \$${assignedProduct.price}',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    ),
  ];
}

}
