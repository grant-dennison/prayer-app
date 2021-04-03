import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';

import '../model/prayer_item.dart';
import '../prayer_context_controller.dart';

class PrayerItemListPage extends Page {
  final List<String> breadcrumbs;

  PrayerItemListPage({
    required this.breadcrumbs,
  }) : super(key: ValueKey(breadcrumbs.join('/') + '/list-page'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return PrayerItemListScreen(
          breadcrumbs: breadcrumbs,
        );
      },
    );
  }
}

class PrayerItemListScreen extends StatelessWidget {
  final List<String> breadcrumbs;

  PrayerItemListScreen({
    required this.breadcrumbs,
  });

  @override
  Widget build(BuildContext context) {
    final dataAccess = Provider.of<PrayerDataAccess>(context);
    return Consumer<NavigationController>(
        builder: (context, navigationController, child) =>
            ChangeNotifierProvider<PrayerContextController>(
              create: (context) => PrayerContextController(
                dataAccess: dataAccess,
                navigationController: navigationController,
                breadcrumbs: breadcrumbs,
              ),
              child: child,
            ),
        child: AppUi());
  }
}

class AppUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerContextController>(
        builder: (context, controller, child) => Scaffold(
              appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text(controller.context.current.description),
                leading: controller.isAtRoot()
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => controller.popContext()),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more),
                    tooltip: 'See prayer details',
                    onPressed: () {
                      print('see more');
                    },
                  )
                ],
              ),
              body: PrayerItemListWidget(),
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final input = await prompt(context);
                  if (input != null && input.isNotEmpty) {
                    controller.addPrayer(input);
                  }
                },
                tooltip: 'Increment',
                child: Icon(Icons.add),
              ), // This trailing comma makes auto-formatting nicer for build methods.
            ));
  }
}

class PrayerItemListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerContextController>(
      builder: (context, controller, child) {
        print('rebuild list');
        final List<PrayerItem> listCopy =
            List.from(controller.context.children);
        listCopy.sort((a, b) {
          final aTime = a.lastPrayed;
          final bTime = b.lastPrayed;
          if (aTime == null) {
            return -1;
          }
          if (bTime == null) {
            return 1;
          }
          return aTime.compareTo(bTime);
        });
        final List prayerItemWidgets =
            listCopy.map((e) => PrayerItemWidget(e)).toList();
        final List<Widget> widgets = [
          if (!controller.isAtRoot())
            GestureDetector(
              onTap: () => controller.popContext(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Go Back", style: TextStyle(fontSize: 40)),
              ),
            ),
          if (prayerItemWidgets.length == 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("(no items in list)", style: TextStyle(fontSize: 40)),
            ),
          ...prayerItemWidgets,
        ];
        return ListView(
          children: widgets,
        );
      },
    );
  }
}

class PrayerItemWidget extends StatelessWidget {
  final PrayerItem prayerItem;

  PrayerItemWidget(this.prayerItem);

  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<PrayerContextController>(context, listen: false);
    return SwipeActionCell(
      key: ValueKey(prayerItem.id + '|' + prayerItem.lastPrayed.toString()),
      performsFirstActionWithFullSwipe: true,
      fullSwipeFactor: 0.3,
      trailingActions: [
        SwipeAction(
          title: 'Mark Prayed',
          icon: const Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.white,
          ),
          onTap: (handler) async {
            await handler(true);
            controller.markPrayed(prayerItem);
          },
          color: Colors.green,
        ),
      ],
      child: GestureDetector(
        onTap: () => controller.pushContext(prayerItem),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Text("${prayerItem.description}", style: TextStyle(fontSize: 40)),
        ),
      ),
    );
  }
}
