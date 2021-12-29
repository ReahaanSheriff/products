import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:product_crud/location.dart';
import 'package:product_crud/login.dart';
import 'package:product_crud/singleProduct.dart';
import 'package:product_crud/webview.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  CollectionReference _productss =
      FirebaseFirestore.instance.collection('products');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
      _imageController.text = documentSnapshot['imageUrl'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            //padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Price',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    controller: _imageController,
                    decoration: InputDecoration(labelText: 'ImageUrl'),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: ElevatedButton(
                      child: Text(action == 'create' ? 'Create' : 'Update'),
                      onPressed: () async {
                        final String? name = _nameController.text;
                        final double? price =
                            double.tryParse(_priceController.text);
                        final String? image = _imageController.text;
                        final String? id = generateId();
                        if (name != null && price != null) {
                          if (action == 'create') {
                            // Persist a new product to Firestore
                            await _productss.add({
                              "name": name,
                              "price": price,
                              "imageUrl": image,
                              "pid": id.toString()
                            });
                          }

                          if (action == 'update') {
                            // Update the product
                            await _productss.doc(documentSnapshot!.id).update({
                              "name": name,
                              "price": price,
                              "imageUrl": image
                            });
                          }

                          // Clear the text fields
                          _nameController.text = '';
                          _priceController.text = '';
                          _imageController.text = '';

                          // Hide the bottom sheet
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  // Deleteing a product by id
  Future<void> _deleteProduct(String productId) async {
    await _productss.doc(productId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You have successfully deleted a product')));
  }

  String generateId() {
    var rnd = new Random();
    var next = rnd.nextDouble() * 1000000;
    while (next < 100000) {
      next *= 10;
    }

    return ('ID' + next.toInt().toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Products'),
          actions: [
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewMobile()));
                    },
                    icon: Icon(Icons.public)),
                IconButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut().then((_) =>
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => Login()),
                              (route) => false));
                    },
                    icon: Icon(Icons.logout)),
              ],
            )
          ],
        ),
        // Using StreamBuilder to display all products from Firestore in real-time
        body: StreamBuilder(
          stream: _productss.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SingleProduct(
                                  data: documentSnapshot['pid'])));
                    },
                    child: Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.network(documentSnapshot['imageUrl']),
                        title: Text(documentSnapshot['pid'] +
                            "\n" +
                            documentSnapshot['name']),
                        subtitle: Text(documentSnapshot['price'].toString()),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              // Press this button to edit a single product
                              IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      _createOrUpdate(documentSnapshot)),
                              // This icon button is used to delete a single product
                              IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteProduct(documentSnapshot.id)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          new FloatingActionButton(
            onPressed: () => _createOrUpdate(),
            child: Icon(Icons.add),
          ),
          SizedBox(
            width: 20,
          ),
          new FloatingActionButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => CurrentLocation())),
            child: Icon(Icons.location_city),
          ),
        ])

        // // Add new product
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => _createOrUpdate(),
        //   child: Icon(Icons.add),
        // ),

        );
  }
}
