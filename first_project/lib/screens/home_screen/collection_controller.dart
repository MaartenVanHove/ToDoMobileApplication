import 'package:first_project/models/todo_list.dart';
import 'package:flutter/material.dart';

class CollectionController extends ChangeNotifier {
  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  /// Filters and Sorts the collections list
  List<TodoList> getProcessedCollections(List<TodoList> allLists) {
    // 1. Filter based on search
    final filtered = allLists.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    
    return filtered;
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = "";
    notifyListeners();
  }
}