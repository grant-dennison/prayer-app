import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:prayer_app/data/default_data.dart';
import 'package:prayer_app/data/export_data.dart';
import 'package:prayer_app/data/hive/boxes.dart';
import 'package:prayer_app/data/root_prayer_item.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
import 'package:prayer_app/navigation/page_spec.dart';
import 'package:prayer_app/navigation/page_type.dart';
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

typedef Future<void> _FutureCallback();

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final navigationController = Provider.of<NavigationController>(context);
    final boxes = Provider.of<Boxes>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => navigationController
                  .pushContext(PageSpec.list(prayerItemId: rootPrayerItemId)),
              child: const Text('Pray'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () => navigationController.pushContext(PageSpec(
                prayerItemId: null,
                pageType: PageType.answeredList,
              )),
              child: const Text('Reflect'),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      _withLoadingScreen(() => exportDataToFiles(boxes)),
                  child: const Text('Backup'),
                ),
                SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () =>
                      _withLoadingScreen(() => importDataFromFiles(boxes)),
                  child: const Text('Restore'),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            // DeleteButton(),
            // SizedBox(height: 10.0),
            Text('v1.1.0'),
          ],
        ),
      ),
    );
  }

  Future<void> _withLoadingScreen(Future<void> Function() callback) async {
    setState(() {
      _loading = true;
    });
    try {
      await callback();
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
          await ensureDefaultData(boxes);
          // TODO: Somehow need to recreate root prayer item.
        }
      },
      child: const Text('Delete Data'),
    );
  }
}
