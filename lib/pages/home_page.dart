import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:home_module_17/models/view_types.dart';

import 'data_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ViewTypes currentViewType = ViewTypes.all;
  final storage = FirebaseStorage.instance;

  Widget getStyleItem(String text, ViewTypes type) {
    var widget = (currentViewType == type)
        ? Text(
      text,
      style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16),
    )
        : Text(text);
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<ViewTypes>(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              value: currentViewType,
              elevation: 12,
              isDense: true,
              dropdownColor: Colors.indigo[300],
              onChanged: (newValue) {
                setState(() {
                  currentViewType = newValue!;
                });
              },
              items: [
                DropdownMenuItem(
                  value: ViewTypes.all,
                  child: getStyleItem('Show all', ViewTypes.all),
                ),
                DropdownMenuItem(
                  value: ViewTypes.orderByName,
                  child: getStyleItem('Order by name', ViewTypes.orderByName),
                ),
                DropdownMenuItem(
                  value: ViewTypes.orderByIsBought,
                  child: getStyleItem(
                      'Order by bought', ViewTypes.orderByIsBought),
                ),
                DropdownMenuItem(
                  value: ViewTypes.findIsBought,
                  child: getStyleItem('Find bought', ViewTypes.findIsBought),
                ),
                DropdownMenuItem(
                  value: ViewTypes.findIsNotBought,
                  child: getStyleItem(
                      'Find no bought', ViewTypes.findIsNotBought),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: storage.ref('background.jpg').getDownloadURL(),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.done
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.fitHeight,
                        image: NetworkImage(snapshot.data!),
                      ),
                    ),
                    child: DataPage(currentViewType: currentViewType),
                  )
                : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}