import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:prayer_app/model/prayer_update.dart';
import 'package:prayer_app/navigation/page_spec.dart';
import 'package:provider/provider.dart';

import '../prayer_context_controller.dart';
import 'prayer_context_controller_provider.dart';

class PrayerItemDetailsPage extends Page {
  final List<String> breadcrumbs;

  PrayerItemDetailsPage({
    required this.breadcrumbs,
  });

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
    final controller = Provider.of<PrayerContextController>(context);
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: Text(controller.context.current.description),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              tooltip: 'See list',
              onPressed: () {
                controller.navigation.pushContext(PageSpec.list(
                  prayerItemId: controller.context.current.id,
                ));
              },
            ),
          ],
        ),
        body: PrayerItemUpdates(),
      ),
    );
  }
}

class PrayerItemDetailsTop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PrayerItemDetailsSummary(),
        PrayerItemUpdateInput(),
      ],
    );
  }
}

class PrayerItemDetailsSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PrayerContextController>(context);
    final timesPrayed = controller.context.current.timesPrayed;
    final prayedSince = DateTimeFormat.format(
        controller.context.current.created,
        format: 'D, M j Y');
    final answered = controller.context.current.answered == null
        ? null
        : DateTimeFormat.format(controller.context.current.answered!,
            format: 'D, M j Y');
    return Padding(
      padding: cardPadding,
      child: Column(
        children: [
          if (answered != null)
            Text('Answered! $answered',
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                )),
          Text(
            'Prayed $timesPrayed times since $prayedSince',
            style: const TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}

class PrayerItemUpdates extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PrayerContextController>(context);
    final updateHelper = controller.context.updates;
    return ListView.builder(
      itemCount: updateHelper.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return PrayerItemDetailsTop();
        }
        return FutureBuilder(
          future: updateHelper.getUpdate(index - 1),
          builder: (context, AsyncSnapshot<PrayerUpdate> snapshot) {
            if (snapshot.hasData) {
              return PrayerItemUpdate(update: snapshot.data!);
            } else {
              return const Text('LOADING...');
            }
          },
        );
      },
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
              decoration: const InputDecoration(
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
                child: const Text('Save'),
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
          padding: const EdgeInsets.only(left: 5.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              DateTimeFormat.format(update.time,
                  format: 'D, M j Y, \\a\\t h:i a'),
              style: const TextStyle(
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
