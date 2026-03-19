import 'package:first_project/models/collection.dart';
import 'package:flutter/material.dart';
import 'package:first_project/models/todo_list.dart';

class CollectionController extends ChangeNotifier {
  String _searchQuery = "";
  List<int> _selectedTagIds = [];

  String get searchQuery => _searchQuery;
  List<int> get selectedTagIds => _selectedTagIds;

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = "";
    notifyListeners();
  }

  void toggleTagSelection(int tagId) {
    _selectedTagIds.contains(tagId)
        ? _selectedTagIds.remove(tagId)
        : _selectedTagIds.add(tagId);

    notifyListeners();
  }

  void clearTags() {
    _selectedTagIds = [];
    notifyListeners();
  }

  List<TodoList> getProcessedLists(List<TodoList> allLists) {
    return allLists.where((list) {
      return _matchesSearchBar(list) && _matchesTags(list);
    }).toList();
  }

  bool _matchesSearchBar(TodoList list) {
    if (_searchQuery.isEmpty) return true;
    return list.name.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  bool _matchesTags(TodoList list) {
    if (_selectedTagIds.isEmpty) return true;

    final currentListTags = list.tags;
    final currentListTagIds = currentListTags.map((t) => t.id).toList();

    return _selectedTagIds.any(
      (filterId) => currentListTagIds.contains(filterId),
    );
  }

  List<Collection> sortCollection(
    List<Collection> collections,
    Map<int, List<TodoList>> allListsMap,
  ) {
    // Create a copy to avoid mutating the original list
    List<Collection> sorted = List.from(collections);

    if (_selectedTagIds.isEmpty) return sorted;

    sorted.sort((a, b) {
      // Get the count for each collection, default to 0 if none found
      final countA = allListsMap[a.id]?.length ?? 0;
      final countB = allListsMap[b.id]?.length ?? 0;

      // Sort descending (highest count first)
      return countB.compareTo(countA);
    });

    return sorted;
  }

  Map<int, List<TodoList>> getFilteredListsMap(
    Map<int, List<TodoList>> allListsMap,
  ) {
    final Map<int, List<TodoList>> filteredMap = {};

    // Iterate through each collection entry in the map
    for (var entry in allListsMap.entries) {
      int collectionId = entry.key;
      List<TodoList> listsInCollection = entry.value;

      // Filter the lists within this specific collection
      final filteredLists = listsInCollection.where((list) {
        return _matchesSearchBar(list) && _matchesTags(list);
      }).toList();

      // Only add the collection to the map if it has lists remaining after filtering
      if (filteredLists.isNotEmpty) {
        filteredMap[collectionId] = filteredLists;
      }
    }

    return filteredMap;
  }
}
