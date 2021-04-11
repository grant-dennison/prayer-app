import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:prayer_app/data/hive/boxes.dart';
import 'package:prayer_app/data/root_prayer_item.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
import 'package:provider/provider.dart';

class HomePage extends Page {
  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return HomeScreen();
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navigationController = Provider.of<NavigationController>(context);
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => navigationController.pushContext(rootPrayerItem),
            child: const Text('Pray'),
          ),
          DeleteButton(),
        ],
      )),
    );
  }
}

const _deleteConfirmation = 'DELETE';

class DeleteButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final boxes = Provider.of<Boxes>(context);
    return ElevatedButton(
      onPressed: () async {
        final result = await showModalActionSheet(
          context: context,
          title: 'Are you sure you want to delete everything?',
          actions: [
            SheetAction(
              key: _deleteConfirmation,
              label: 'Yes, delete everything',
              isDestructiveAction: true,
            ),
          ],
        );
        if (result == _deleteConfirmation) {
          await boxes.idList.deleteAll(boxes.idList.keys);
          await boxes.idListChunk.deleteAll(boxes.idListChunk.keys);
          await boxes.prayer.deleteAll(boxes.prayer.keys);
          await boxes.prayerUpdate.deleteAll(boxes.prayerUpdate.keys);
          // TODO: Somehow need to recreate root prayer item.
        }
      },
      child: const Text('Delete Data'),
    );
  }
}
