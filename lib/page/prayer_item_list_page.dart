import 'package:flutter/material.dart';
import 'package:prayer_app/page/prayer_context_controller_provider.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';

import '../model/prayer_item.dart';
import '../prayer_context_controller.dart';

class PrayerItemListPage extends Page {
  final List<String> breadcrumbs;

  PrayerItemListPage({
    required this.breadcrumbs,
  }) : super(key: ValueKey('${breadcrumbs.join('/')}/list-page'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return PrayerContextControllerProvider(
          breadcrumbs: breadcrumbs,
          child: PrayerItemListScreen(),
        );
      },
    );
  }
}

class PrayerItemListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerContextController>(
      builder: (context, controller, child) => Scaffold(
        appBar: AppBar(
          title: Text(controller.context.current.description),
          actions: [
            if (!controller.isAtRoot())
              IconButton(
                icon: const Icon(Icons.more),
                tooltip: 'See prayer details',
                onPressed: () {
                  controller.navigation.toggleDetails(show: true);
                },
              )
          ],
        ),
        body: child,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final input = await prompt(context);
            if (input != null && input.isNotEmpty) {
              await controller.addPrayer(input);
            }
          },
          tooltip: 'Add Prayer',
          child: const Icon(Icons.add),
        ),
      ),
      child: PrayerItemListWidget(),
    );
  }
}

class PrayerItemListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerContextController>(
      builder: (context, controller, child) {
        final listCopy = List<PrayerItem>.from(controller.context.children);
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
        final List<Widget> prayerItemWidgets =
            listCopy.map((e) => PrayerItemWidget(e)).toList();
        final widgets = [
          if (prayerItemWidgets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('(no items in list)',
                  style: TextStyle(
                    fontSize: 40,
                    fontStyle: FontStyle.italic,
                  )),
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

  const PrayerItemWidget(this.prayerItem);

  @override
  Widget build(BuildContext context) {
    final controller =
        Provider.of<PrayerContextController>(context, listen: false);
    return Dismissible(
      key: ValueKey('${prayerItem.id}|${prayerItem.lastPrayed}'),
      background: Container(
        color: Colors.green,
      ),
      onDismissed: (direction) => controller.markPrayed(prayerItem),
      child: GestureDetector(
        onTap: () => controller.navigation.pushContext(prayerItem),
        child: ListTile(
          title: Text(
            prayerItem.description,
            style: const TextStyle(fontSize: 40),
          ),
        ),
      ),
    );
  }
}
