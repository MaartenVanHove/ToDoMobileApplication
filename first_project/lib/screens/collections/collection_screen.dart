import 'package:first_project/providers/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CollectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text("COLLECTIONS"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: appState.collections.length,
        itemBuilder: (context, index) {
          final collection = appState.collections[index];
          final lists = appState.todoLists[collection.id] ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  collection.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          );          
        }
      ),
    );
  }

  // Widget _horizontalScrolling() {
  //   return 
  // }

}