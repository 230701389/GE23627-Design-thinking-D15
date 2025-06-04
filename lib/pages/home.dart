import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/pages/selection.dart';

class HomePage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> getFoodPlaces() async {
    List<Map<String, dynamic>> foodPlaces = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('food_places').get();

      for (var doc in snapshot.docs) {
        foodPlaces.add(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    return foodPlaces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getFoodPlaces(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.data == null) {
              return Center(child: Text("No food places available"));
            } else {
              List<Map<String, dynamic>> foodPlaces = snapshot.data!;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1, // Makes the widgets square
                ),
                itemCount: foodPlaces.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      print("Tapped on ${foodPlaces[index]['name']}");
                      // Navigate to the selected food place screen if needed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FoodSelectionPage(place: foodPlaces[index]),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              foodPlaces[index]['image']!,
                              height: 135,
                              width: 150,
                              colorBlendMode: BlendMode.color,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            foodPlaces[index]['name']!,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
