class AppStrings {
  static const Map<String, Map<String, String>> _strings = {
    'list_screen': {
      'empty_state': 'No cards yet! 🎉',
      'hint_text': 'Enter new Task...',
      'undo_tooltip': 'Undo finished task',
    },
    'collection_screen': {
      'title': 'My Collections',
      'add_list_hint': 'Create a new list name...',
    },
    'dialogs': {
      'rename_title': "Change name",
      'cancel': 'Cancel',
      'save': 'Save',
    },
  };

  // The "Selector" method
  static String get(String page, String key) {
    return _strings[page]?[key] ?? "String not found";
  }
}