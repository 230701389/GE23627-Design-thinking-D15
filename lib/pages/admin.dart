import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/pages/food.dart';

class AdminPage extends StatelessWidget {
  void _addNewPlace(BuildContext context) {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Canteen"),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: "Canteen Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                FirebaseFirestore.instance.collection('food_places').add({
                  'name': nameController.text,
                });
                Navigator.pop(context);
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    );
  }

  void _deletePlace(String placeId) {
    FirebaseFirestore.instance.collection('food_places').doc(placeId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin - Canteen Management")),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('food_places').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          var places = snapshot.data!.docs;
          return ListView.builder(
            itemCount: places.length,
            itemBuilder: (context, index) {
              var place = places[index];
              return ListTile(
                title: Text(place['name']),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deletePlace(place.id),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodManagementPage(
                          placeId: place['name'], placeName: place['name']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewPlace(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
