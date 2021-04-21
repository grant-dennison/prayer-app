import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:prayer_app/page/prayer_context_controller_provider.dart';
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
            final input = await showTextInputDialog(
              context: context,
              title: 'New Prayer',
              message: 'Enter new prayer text',
              textFields: [
                DialogTextField(hintText: 'my care'),
              ],
            );
            if (input != null && input.isNotEmpty) {
              await controller.addPrayer(input[0]);
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
      child: FocusedMenuHolder(
        menuOffset: 10.0,
        menuItems: [
          FocusedMenuItem(
            title: Text('Move'),
            onPressed: () async {
              final parent = controller.context.parent;
              final whereTo = await showConfirmationDialog<PrayerItem>(
                context: context,
                title: 'Where to?',
                actions: [
                  if (parent != null)
                    AlertDialogAction(
                        key: parent, label: '(UP) ${parent.description}'),
                  ...controller.context.children
                      .where((e) => e != prayerItem)
                      .map((e) =>
                          AlertDialogAction(key: e, label: e.description)),
                ],
              );
              if (whereTo != null) {
                await controller.movePrayer(prayerItem, whereTo);
              }
            },
          ),
          FocusedMenuItem(
            title: Text('Edit'),
            onPressed: () async {
              final input = await showTextInputDialog(
                context: context,
                title: 'Edit Prayer',
                message: 'Enter new prayer text',
                textFields: [
                  DialogTextField(
                      hintText: 'my care', initialText: prayerItem.description),
                ],
              );
              if (input != null && input.isNotEmpty) {
                await controller.editPrayer(prayerItem, input[0]);
              }
            },
          ),
          FocusedMenuItem(
            title: Text('Mark Answered'),
            onPressed: () {
              print('mark answered pressed');
            },
          ),
          FocusedMenuItem(
            title: Text('Remove'),
            onPressed: () async {
              final result = await showOkCancelAlertDialog(
                context: context,
                title: 'Confirm Remove',
                okLabel: 'Remove',
                cancelLabel: 'Cancel',
              );
              if (result == OkCancelResult.ok) {
                await controller.removePrayer(prayerItem);
              }
            },
          ),
        ],
        onPressed: () {},
        child: Container(
          color: Theme.of(context).cardColor,
          child: GestureDetector(
            onTap: () => controller.navigation.pushContext(prayerItem),
            child: ListTile(
              title: Text(
                prayerItem.description,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
