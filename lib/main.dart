import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:provider/provider.dart';

import 'model/prayer_item.dart';
import 'prayer_context_controller.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late PrayerDataAccess prayerDataAccess;
  late PrayerContextController prayerContextController;

  @override
  void initState() {
    super.initState();
    prayerDataAccess = PrayerDataAccess();
    prayerContextController = PrayerContextController(prayerDataAccess);
  }

  @override
  void dispose() {
    prayerContextController.dispose();
    // TODO: prayerDataAccess.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrayerContextController>.value(
      value: prayerContextController,
      child: AppUi(),
    );
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
        final List<Widget> widgets =
            listCopy.map<Widget>((e) => PrayerItemWidget(e)).toList();
        if (widgets.length == 0) {
          widgets.add(Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("(no items in list)", style: TextStyle(fontSize: 40)),
          ));
        }
        if (!controller.isAtRoot()) {
          widgets.insert(
              0,
              GestureDetector(
                onTap: () => controller.popContext(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Go Back", style: TextStyle(fontSize: 40)),
                ),
              ));
        }
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
