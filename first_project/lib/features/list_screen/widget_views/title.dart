import 'package:first_project/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:first_project/model/app_model.dart';
import 'package:first_project/features/list_screen/list_controller.dart';

class ListScreenTitle extends StatelessWidget implements PreferredSizeWidget {
  final int listId;
  final String title;

  const ListScreenTitle({super.key, required this.listId, required this.title});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppModel>();
    final listController = context.watch<ListController>();

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: listController.isEditingTitle
          ? TextField(
              controller: listController.titleEditController,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(border: InputBorder.none),
              onSubmitted: (_) =>
                  listController.stopEditingTitle(appState, listId),
              onTapOutside: (_) =>
                  listController.stopEditingTitle(appState, listId),
            )
          : GestureDetector(
              onTap: () => listController.startEditingTitle(title),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 32,
                ),
              ),
            ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white70, size: 28),
          color: const Color(0xFF162238), // Kleur van het menu (donker thema)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            // Hier handelen we de keuzes af
            if (value == 'rename') {
              listController.startEditingTitle(title);
            } else if (value == 'image') {
              listController.updateListImage(
                appState,
                listId,
                ImageSource.gallery,
              );
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'rename',
              child: ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                title: Text(
                  AppStrings.get('list_screen', 'rename'),
                  style: TextStyle(color: Colors.white),
                ),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
            PopupMenuItem<String>(
              value: 'image',
              child: ListTile(
                leading: Icon(Icons.image, color: Colors.white),
                title: Text(
                  AppStrings.get('list_screen', 'change_image'),
                  style: TextStyle(color: Colors.white),
                ),
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
