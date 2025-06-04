import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodManagementPage extends StatefulWidget {
  final String placeId;
  final String placeName;

  FoodManagementPage({required this.placeId, required this.placeName});

  @override
  _FoodManagementPageState createState() => _FoodManagementPageState();
}

class _FoodManagementPageState extends State<FoodManagementPage> {
  void _addOrUpdateFoodItem(
      {String? foodId,
      String? name,
      double? price,
      int? quantity,
      String? imageUrl}) {
    TextEditingController nameController =
        TextEditingController(text: name ?? '');
    TextEditingController priceController =
        TextEditingController(text: price != null ? price.toString() : '');
    TextEditingController quantityController = TextEditingController(
        text: quantity != null ? quantity.toString() : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(foodId == null ? "Add Food Item" : "Update Food Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Food Name")),
            TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number),
            TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: "Quantity"),
                keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              double price = double.tryParse(priceController.text) ?? 0;
              int quantity = int.tryParse(quantityController.text) ?? 0;

              if (nameController.text.isNotEmpty && price > 0 && quantity > 0) {
                if (foodId == null) {
                  FirebaseFirestore.instance.collection('food_items').add({
                    'place_id': widget.placeId,
                    'name': nameController.text,
                    'price': price,
                    'quantity': quantity,
                    'image': imageUrl ?? '',
                  });
                } else {
                  FirebaseFirestore.instance
                      .collection('food_items')
                      .doc(foodId)
                      .update({
                    'name': nameController.text,
                    'price': price,
                    'quantity': quantity,
                  });
                }
                Navigator.pop(context);
              }
            },
            child: Text(foodId == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  void _deleteFoodItem(String foodId) {
    FirebaseFirestore.instance.collection('food_items').doc(foodId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Food - ${widget.placeName}")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('food_items')
            .where("place_id", isEqualTo: widget.placeId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var foodItems = snapshot.data!.docs;
          return ListView.builder(
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              var foodItem = foodItems[index];
              return ListTile(
                leading: Image.network(foodItem['image'],
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text(foodItem['name']),
                subtitle: Text(
                    "₹${foodItem['price']} | Qty: ${foodItem['quantity']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _addOrUpdateFoodItem(
                        foodId: foodItem.id,
                        name: foodItem['name'],
                        price: foodItem['price'].toDouble(),
                        quantity: foodItem['quantity'],
                        imageUrl: foodItem['image'],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFoodItem(foodItem.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateFoodItem(),
        child: Icon(Icons.add),
      ),
    );
  }
}
