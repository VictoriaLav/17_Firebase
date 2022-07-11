import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../models/view_types.dart';
import '../models/shopping_list.dart';
import '../models/products.dart';

class DataPage extends StatefulWidget {
  const DataPage({Key? key, required this.currentViewType}) : super(key: key);
  final ViewTypes currentViewType;

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  ShoppingList _shoppingList = ShoppingList();
  final _nameController = TextEditingController();
  bool isBought = false;

  void _submit() {
    setState(() {
      _shoppingList.addProduct(_nameController.text, isBought);
    });
    _nameController.text = '';
    isBought = false;
  }

  Future<void> editProduct(bool isBought, DocumentReference<Product> reference) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.update(reference, {"isBought": isBought});
    await batch.commit();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Expanded(
          child: Consumer<ShoppingList>(
            builder: (context, state, child) =>
                StreamBuilder<QuerySnapshot<Product>>(
              stream: state.shopping
                  .queryBy(widget.currentViewType, state.shopping)
                  .snapshots(),
              //_shopping.queryBy(widget.currentViewType, _shopping).snapshots(),
              builder: (context, snapshot) => snapshot.hasData
                  ? ListView.builder(
                      itemCount: snapshot.data?.size,
                      itemBuilder: (BuildContext context, int index) {
                        var product = snapshot.data?.docs[index].data();
                        var reference = snapshot.data?.docs[index].reference;
                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(product!.name),
                              Checkbox(
                                value: product.isBought,
                                onChanged: (bool? value) {
                                  editProduct(value!, reference!);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  : const Text('Empty!'),
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: Padding(
            padding: EdgeInsets.all(5.0),
            child: Row(
              children: <Widget>[
                Text('Bought?'),
                Checkbox(
                  value: isBought,
                  onChanged: (bool? value) {
                    setState(() {
                      isBought = value!;
                    });
                  },
                ),
                Flexible(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(hintText: 'Product'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension on Query<Product> {
  Query<Product> queryBy(ViewTypes type, Query<Product> query) {
    switch (type) {
      case ViewTypes.all:
        return query;
      case ViewTypes.findIsBought:
        return where('isBought', isEqualTo: true);
      case ViewTypes.findIsNotBought:
        return where('isBought', isEqualTo: false);
      case ViewTypes.orderByName:
        return orderBy('name');
      case ViewTypes.orderByIsBought:
        return orderBy('isBought', descending: true);
      default:
        return query;
    }
  }
}