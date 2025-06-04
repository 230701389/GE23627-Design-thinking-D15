import 'package:flutter/material.dart';
import 'package:myapp/pages/payment.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> selectedItems;
  final double totalPrice;

  CheckoutPage({required this.selectedItems, required this.totalPrice});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late List<Map<String, dynamic>> selectedItems;
  late double totalPrice;

  @override
  void initState() {
    super.initState();
    selectedItems = List.from(widget.selectedItems); // Copy selected items
    totalPrice = widget.totalPrice; // Copy total price
  }

  void updateQuantity(int index, int change) {
    setState(() {
      selectedItems[index]["count"] += change;

      if (selectedItems[index]["count"] <= 0) {
        selectedItems.removeAt(index);
      }

      // Recalculate total price
      totalPrice = selectedItems.fold(
        0,
        (sum, item) => sum + (item["price"] * item["count"]),
      );
    });
  }

  void removeItem(int index) {
    setState(() {
      selectedItems.removeAt(index);
      // Recalculate total price
      totalPrice = selectedItems.fold(
        0,
        (sum, item) => sum + (item["price"] * item["count"]),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Checkout"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context, selectedItems); //  Ensure updated list is returned
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              "Total Price: ₹${totalPrice.toStringAsFixed(2)}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: selectedItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          selectedItems[index]["image"],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(selectedItems[index]["name"]),
                      subtitle: Text("₹${selectedItems[index]["price"]}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Colors.red),
                            onPressed: () => updateQuantity(index, -1),
                          ),
                          Text(
                            "${selectedItems[index]["count"]}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: Colors.green),
                            onPressed: () => updateQuantity(index, 1),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,
                                color: const Color.fromARGB(255, 234, 25, 25)),
                            onPressed: () => removeItem(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpiPaymentPage(
                      amount: totalPrice,
                      upiId:
                          "udhayakumar00615@okicici", // Replace with your actual UPI ID
                      payeeName: "Your Business Name",
                    ),
                  ),
                );
              },
              child: Text("Proceed to Pay"),
            )
          ],
        ),
      ),
    );
  }
}
