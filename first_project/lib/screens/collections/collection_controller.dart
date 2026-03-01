import 'package:flutter/material.dart';
import 'package:first_project/models/collection.dart';

class CollectionController extends ChangeNotifier {
  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  /// Filters and Sorts the collections list
  List<Collection> getProcessedCollections(List<Collection> allCollections) {
    // 1. Filter based on search
    final filtered = allCollections.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // 2. Sort Alphabetically
    filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    
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