import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'products.dart';

class ShoppingList with ChangeNotifier {
  late CollectionReference<Product> shopping;

  ShoppingList() {
    shopping = initData();
    notifyListeners();
  }

  CollectionReference<Product> initData() {
    CollectionReference<Product> _listData = FirebaseFirestore.instance
        .collection('shopping')
        .withConverter<Product>(
      fromFirestore: (snapshots, _) => Product.fromJson(snapshots.data()!),
      toFirestore: (movie, _) => movie.toJson(),
    );
    return _listData;
  }

  void addProduct(String name, bool isBought) {
    shopping.add(Product(
      name: name,
      isBought: isBought,
    ));
    notifyListeners();
  }
}
