import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SingleProduct extends StatefulWidget {
  final String data;
  const SingleProduct({Key? key, required this.data}) : super(key: key);

  @override
  _SingleProductState createState() => _SingleProductState();
}

class _SingleProductState extends State<SingleProduct> {
  CollectionReference _productss =
      FirebaseFirestore.instance.collection('products');
  var pid, pname, pprice, pimage;
  Future<void> getData() async {
    // Get docs from collection reference
    QuerySnapshot querySnapshot =
        await _productss.where("pid", isEqualTo: widget.data).get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data());

    print(allData);

    for (var i in allData) {
      pprice = i['price'].toString();
      pname = i['name'];
      pimage = i['imageUrl'];
      pid = i['pid'].toString();
    }
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("single"),
      ),
      body: Container(
        height: 400,
        // for(var i in)
        child: Column(
          children: [
            Image.network(
              pimage == null
                  ? "https://static.vecteezy.com/system/resources/previews/001/826/248/non_2x/progress-loading-bar-buffering-download-upload-and-loading-icon-vector.jpg"
                  : pimage,
              height: 300,
            ),
            Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Column(
                  children: [
                    Text(pid == null ? "loading..." : pid),
                    Text(pname == null ? "loading..." : pname),
                  ],
                ),
                subtitle: Column(
                  children: [
                    Text(pprice == null ? "loading...." : pprice),
                  ],
                ),
                // trailing: SizedBox(
                //   width: 100,
                //   child: Row(
                //     children: [
                //       // Press this button to edit a single product
                //       // IconButton(
                //       //     icon: Icon(Icons.edit),
                //       //     onPressed: () =>
                //       //         _createOrUpdate(documentSnapshot)),
                //       // // This icon button is used to delete a single product
                //       // IconButton(
                //       //     icon: Icon(Icons.delete),
                //       //     onPressed: () =>
                //       //         _deleteProduct(documentSnapshot.id)),
                //     ],
                //   ),
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
