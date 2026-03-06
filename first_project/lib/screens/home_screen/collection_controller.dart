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

    // 3. Check if every selected filter ID exists in the list's own IDs
    print('ListId: ${list.id} ListTags: ${list.tags} SelectedTags: ${_selectedTagIds}');
    return _selectedTagIds.every((filterId) => currentListTagIds.contains(filterId));
  }
}