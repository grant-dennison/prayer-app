import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:prayer_app/model/prayer_update.dart';
import 'package:provider/provider.dart';

import '../prayer_context_controller.dart';
import 'prayer_context_controller_provider.dart';

class PrayerItemDetailsPage extends Page {
  final List<String> breadcrumbs;

  PrayerItemDetailsPage({
    required this.breadcrumbs,
  }) : super(key: ValueKey(breadcrumbs.join('/') + '/details-page'));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return PrayerContextControllerProvider(
          breadcrumbs: breadcrumbs,
          child: PrayerItemDetailsScreen(),
        );
      },
    );
  }
}

class PrayerItemDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerContextController>(
      builder: (context, controller, child) => KeyboardDismisser(
        child: Scaffold(
          appBar: AppBar(
            title: Text(controller.context.current.description),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => controller.navigation.toggleDetails(false)),
          ),
          body: child,
        ),
      ),
      child: ListView(
        children: [
          PrayerItemDetailsSummary(),
          PrayerItemUpdates(),
        ],
      ),
    );
  }
}

class PrayerItemDetailsSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PrayerContextController>(context);
    return Padding(
      padding: cardPadding,
      child: Text(
        'Prayed X times since X date/time',
        style: TextStyle(
          fontSize: 20.0,
        ),
      ),
    );
  }
}

class PrayerItemUpdates extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PrayerContextController>(context);
    final List<PrayerUpdate> updates = List.from(controller.context.updates);
    updates.sort((a, b) => b.time.compareTo(a.time));
    final List<Widget> children = [
      PrayerItemUpdateInput(),
      ...updates.map((e) => PrayerItemUpdate(update: e)).toList()
    ];
    return Column(
      children: children,
    );
  }
}

class PrayerItemUpdateInput extends StatefulWidget {
  @override
  _PrayerItemUpdateInputState createState() => _PrayerItemUpdateInputState();
}

const cardPadding = EdgeInsets.all(10.0);

class _PrayerItemUpdateInputState extends State<PrayerItemUpdateInput> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PrayerContextController>(context);
    return Card(
      child: Padding(
        padding: cardPadding,
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                // border: OutlineInputBorder(),
                hintText: 'Write an update...',
              ),
              onSubmitted: (value) {
                controller.addUpdate(value);
                textController.clear();
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {
                  controller.addUpdate(textController.text);
                  textController.clear();
                },
                child: Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class PrayerItemUpdate extends StatelessWidget {
  final PrayerUpdate update;

  const PrayerItemUpdate({Key? key, required this.update}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 5.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              DateTimeFormat.format(update.time,
                  format: 'D, M j, \\a\\t h:i a'),
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: cardPadding,
            child: Text(update.text),
          ),
        ),
      ],
    );
  }
}
