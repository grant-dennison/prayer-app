import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:prayer_app/navigation/page_spec.dart';
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
                  controller.navigation.pushContext(PageSpec.details(
                    prayerItemId: controller.context.current.id,
                  ));
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
        if (listCopy.isEmpty) {
          return Center(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('No items in this list.',
                      style: TextStyle(
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                      )),
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                      'You may want to add some items using the button below or look at details for this prayer request using the button in the top right.',
                      style: TextStyle(
                        // fontSize: 24,
                        fontStyle: FontStyle.italic,
                      )),
                ),
              ],
            ),
          );
        }
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
        return ListView(
          children: prayerItemWidgets,
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
    final lastPrayed = prayerItem.lastPrayed == null
        ? 'never'
        : DateTimeFormat.format(prayerItem.lastPrayed!, format: 'D, M j Y');
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
            onPressed: () async {
              final result = await showOkCancelAlertDialog(
                context: context,
                title: 'Confirm Mark Answered',
                message:
                    'Do you mean to mark this prayer as answered? This action is irreversible.',
                okLabel: 'Mark Answered',
                cancelLabel: 'Cancel',
              );
              if (result == OkCancelResult.ok) {
                await controller.markAnswered(prayerItem);
              }
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
            onTap: () => controller.navigation
                .pushContext(PageSpec.list(prayerItemId: prayerItem.id)),
            child: ListTile(
              title: Text(
                prayerItem.description,
                style: const TextStyle(fontSize: 24),
              ),
              subtitle: Text('last prayed $lastPrayed'),
            ),
          ),
        ),
      ),
    );
  }
}
