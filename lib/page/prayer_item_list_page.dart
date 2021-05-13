import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:prayer_app/data/root_prayer_item.dart';
import 'package:prayer_app/navigation/page_spec.dart';
import 'package:prayer_app/page/prayer_context_controller_provider.dart';
import 'package:provider/provider.dart';

import '../model/prayer_item.dart';
import '../prayer_context_controller.dart';

class PrayerItemListPage extends Page {
  final List<String> breadcrumbs;

  PrayerItemListPage({
    required this.breadcrumbs,
  });

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
    final controller = Provider.of<PrayerContextController>(context);
    final hasUpdates = controller.context.current.updateCount > 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.context.current.description),
        actions: [
          if (!controller.isAtRoot())
            IconButton(
              icon: hasUpdates
                  ? const Icon(Icons.more)
                  : const Icon(Icons.more_outlined),
              tooltip: 'See prayer details',
              onPressed: () {
                controller.navigation.pushContext(PageSpec.details(
                  prayerItemId: controller.context.current.id,
                ));
              },
            ),
        ],
      ),
      body: PrayerItemListWidget(),
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
    Icon? trailingIcon;
    if (prayerItem.childCount > 0) {
      trailingIcon = const Icon(Icons.account_tree);
    } else if (prayerItem.updateCount > 0) {
      trailingIcon = const Icon(Icons.notes);
    }
    const markPrayedIcon = Icon(
      Icons.low_priority,
      color: Colors.white,
    );
    const markPrayedText = Text(
      'Mark Prayed',
      style: TextStyle(
        color: Colors.white,
      ),
    );
    return Dismissible(
      key: ValueKey('${prayerItem.id}|${prayerItem.lastPrayed}'),
      background: Container(
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.only(left: 4.0),
              child: Row(
                children: [
                  markPrayedIcon,
                  SizedBox(width: 4.0),
                  markPrayedText,
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 4.0),
              child: Row(
                children: [
                  markPrayedText,
                  SizedBox(width: 4.0),
                  markPrayedIcon,
                ],
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) => controller.markPrayed(prayerItem),
      child: FocusedMenuHolder(
        menuOffset: 10.0,
        menuItems: [
          FocusedMenuItem(
            title: Text('Move'),
            onPressed: () async {
              final whereTo =
                  await _promptWhereToPrayerItem(context, controller);
              if (whereTo != null) {
                await controller.movePrayer(prayerItem, whereTo);
              }
            },
          ),
          FocusedMenuItem(
            title: Text('Fork'),
            onPressed: () async {
              final whereTo =
                  await _promptWhereToPrayerItem(context, controller);
              if (whereTo != null) {
                await controller.forkPrayer(prayerItem, whereTo);
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
          if (prayerItem.childCount == 0)
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
                message:
                    'This prayer item will be removed from this list but may still exist in other places (e.g. export and any forked locations).',
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
            onTap: () {
              final shouldGoToDetails =
                  prayerItem.childCount == 0 && prayerItem.updateCount > 0;
              if (shouldGoToDetails) {
                controller.navigation
                    .pushContext(PageSpec.details(prayerItemId: prayerItem.id));
              } else {
                controller.navigation
                    .pushContext(PageSpec.list(prayerItemId: prayerItem.id));
              }
            },
            child: ListTile(
              title: Text(
                prayerItem.description,
                style: const TextStyle(fontSize: 24),
              ),
              subtitle: Text('last prayed $lastPrayed'),
              trailing: trailingIcon,
            ),
          ),
        ),
      ),
    );
  }

  Future<PrayerItem?> _promptWhereToPrayerItem(
      BuildContext context, PrayerContextController controller) async {
    final parent = controller.context.parent;
    PrayerItem? rootOption;
    if (parent != null && parent.id != rootPrayerItemId) {
      rootOption = await controller.dataAccess.getPrayerItem(rootPrayerItemId);
    }
    return await showConfirmationDialog<PrayerItem>(
      context: context,
      title: 'Where to?',
      actions: [
        if (rootOption != null)
          AlertDialogAction(
              key: rootOption, label: '(ROOT) ${rootOption.description}'),
        if (parent != null)
          AlertDialogAction(key: parent, label: '(UP) ${parent.description}'),
        ...controller.context.children
            .where((e) => e != prayerItem)
            .map((e) => AlertDialogAction(key: e, label: e.description)),
      ],
    );
  }
}
