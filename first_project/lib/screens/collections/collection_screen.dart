import 'package:first_project/models/collection.dart';
import 'package:first_project/widgets/todo_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:first_project/providers/app_state.dart';

class CollectionsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final List<Collection> collections =
      appState.collections;

    return Scaffold(
      appBar: AppBar(
        title: Text('Collections'),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'collection title',
                  ),
                ),
                _buildTodoTasks(appState)
              ],
            );
          },
        )
      ),
    );
  }

  Widget _buildTodoTasks(MyAppState appState) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        shrinkWrap: true,
        // physics: ,
        itemCount: 10,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return TodoCard(cardName: 'cardName');
        },
      ),
    );
  }
}
