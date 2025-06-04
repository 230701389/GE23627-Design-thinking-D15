import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/pages/checkOut.dart';

class FoodSelectionPage extends StatefulWidget {
  final Map<String, dynamic> place;
  FoodSelectionPage({required this.place});

  @override
  _FoodSelectionPageState createState() => _FoodSelectionPageState();
}

class _FoodSelectionPageState extends State<FoodSelectionPage> {
  List<Map<String, dynamic>> selectedItems = []; // Stores selected food items
  double totalPrice = 0;
  List<String> categories = ["All", "Snacks", "Drinks", "Meals", "Desserts"];
  String selectedCategory = "All";

  Stream<QuerySnapshot> getFoodItems() {
    var query = FirebaseFirestore.instance
        .collection('food_places')
        .where("place_id", isEqualTo: widget.place["name"]);

    if (selectedCategory != "All") {
      query = query.where("category", isEqualTo: selectedCategory);
    }

    return query.snapshots();
  }

  void updateQuantity(Map<String, dynamic> foodItem, int change) {
    setState(() {
      int index =
          selectedItems.indexWhere((item) => item["id"] == foodItem["id"]);

      if (index != -1) {
        selectedItems[index]["count"] += change;
        if (selectedItems[index]["count"] <= 0) {
          selectedItems.removeAt(index);
        }
      } else if (change > 0) {
        selectedItems.add({...foodItem, "count": 1});
      }

      // Recalculate total price
      totalPrice = selectedItems.fold(
          0, (sum, item) => sum + (item["price"] * item["count"]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.place['name']} Menu")),
      body: Column(
        children: [
          // Category Selector
          Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = categories[index];
                      });
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: selectedCategory == categories[index]
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categories[index],
                        style: TextStyle(
                          color: selectedCategory == categories[index]
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Food List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getFoodItems(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                List<Map<String, dynamic>> foodList =
                    snapshot.data!.docs.map((doc) {
                  return {
                    "id": doc.id,
                    "name": doc["name"],
                    "image": doc["image"],
                    "quantity": doc["quantity"],
                    "price": doc["price"],
                  };
                }).toList();

                return ListView.builder(
                  itemCount: foodList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  foodList[index]["image"],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(foodList[index]["name"],
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        "₹${foodList[index]["price"].toStringAsFixed(2)}",
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.green)),
                                    Text(
                                        "Available: ${foodList[index]["quantity"]}",
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.grey)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: Colors.red),
                                    onPressed: () =>
                                        updateQuantity(foodList[index], -1),
                                  ),
                                  Text(
                                    "${selectedItems.firstWhere(
                                      (item) =>
                                          item["id"] == foodList[index]["id"],
                                      orElse: () => {"count": 0},
                                    )["count"]}",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add, color: Colors.green),
                                    onPressed: () =>
                                        updateQuantity(foodList[index], 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Checkout Box
          if (selectedItems.isNotEmpty)
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(15))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Items: ${selectedItems.length}",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      Text("Total Price: ₹${totalPrice.toStringAsFixed(2)}",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutPage(
                              selectedItems: selectedItems,
                              totalPrice: totalPrice),
                        ),
                      );
                      // Update selection list if changed in checkout
                      if (result != null) {
                        setState(() {
                          selectedItems = List.from(result);
                          totalPrice = selectedItems.fold(
                            0,
                            (sum, item) =>
                                sum + (item["price"] * item["count"]),
                          );
                        });
                      }
                    },
                    child: Text("Checkout",
                        style: TextStyle(color: Colors.blue, fontSize: 18)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
