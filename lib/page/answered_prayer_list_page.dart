import 'package:date_time_format/date_time_format.dart';
import 'package:flutter/material.dart';
import 'package:prayer_app/data/prayer_data_access.dart';
import 'package:prayer_app/model/answered_prayer.dart';
import 'package:prayer_app/model/answered_prayer_list_helper.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
import 'package:prayer_app/navigation/page_spec.dart';
import 'package:prayer_app/page/full_page_future_builder.dart';
import 'package:provider/provider.dart';

class AnsweredPrayerListPage extends Page {
  final List<String> breadcrumbs;

  AnsweredPrayerListPage({
    required this.breadcrumbs,
  });

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return ListHelperProvider(
          breadcrumbs: breadcrumbs,
          child: AnsweredPrayerListScreen(),
        );
      },
    );
  }
}

class ListHelperProvider extends StatefulWidget {
  final List<String> breadcrumbs;
  final Widget child;

  const ListHelperProvider({
    required this.breadcrumbs,
    required this.child,
  });

  @override
  _ListHelperProviderState createState() => _ListHelperProviderState();
}

class _ListHelperProviderState extends State<ListHelperProvider> {
  Future<AnsweredPrayerListHelper>? answeredPrayerListHelperFuture;
  PrayerDataAccess? lastDataAccess;
  NavigationController? lastNavigationController;

  Future<AnsweredPrayerListHelper> _getHelperFuture(BuildContext context) {
    final dataAccess = Provider.of<PrayerDataAccess>(context);
    final navigationController = Provider.of<NavigationController>(context);
    var helperFuture = answeredPrayerListHelperFuture;
    if (dataAccess != lastDataAccess ||
        navigationController != lastNavigationController ||
        helperFuture == null) {
      // TODO: This isn't properly rebuilt on pop context.
      helperFuture = _makeHelperFuture(context);
    }
    lastDataAccess = dataAccess;
    lastNavigationController = navigationController;
    answeredPrayerListHelperFuture = helperFuture;
    return helperFuture;
  }

  Future<AnsweredPrayerListHelper> _makeHelperFuture(
      BuildContext context) async {
    final dataAccess = Provider.of<PrayerDataAccess>(context);
    if (widget.breadcrumbs.isEmpty) {
      return dataAccess.getAnsweredPrayerListHelper();
    } else {
      final prayerItem =
          await dataAccess.getPrayerItem(widget.breadcrumbs.last);
      return dataAccess.getAnsweredPrayerListHelper(prayerItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FullPageFutureBuilder<AnsweredPrayerListHelper>(
      future: _getHelperFuture(context),
      readyBuilder: (context, helper) =>
          Provider<AnsweredPrayerListHelper>.value(
        value: helper,
        child: widget.child,
      ),
    );
  }
}

class AnsweredPrayerListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Answered Prayers'),
      ),
      body: AnsweredPrayerListWidget(),
    );
  }
}

class AnsweredPrayerListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final listHelper = Provider.of<AnsweredPrayerListHelper>(context);
    if (listHelper.length == 0) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('(no items in list)',
            style: TextStyle(
              fontSize: 40,
              fontStyle: FontStyle.italic,
            )),
      );
    }
    return ListView.builder(
      itemCount: listHelper.length,
      itemBuilder: (context, index) {
        return FutureBuilder<AnsweredPrayer?>(
          future: listHelper.getAnsweredPrayer(index),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return AnsweredPrayerWidget(snapshot.data!);
            }
            return const ListTile(
              title: Text(
                'loading...',
                style: TextStyle(
                  fontSize: 40,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class AnsweredPrayerWidget extends StatelessWidget {
  final AnsweredPrayer answeredPrayer;

  const AnsweredPrayerWidget(this.answeredPrayer);

  @override
  Widget build(BuildContext context) {
    final navigationController = Provider.of<NavigationController>(context);
    final dateAnswered =
        DateTimeFormat.format(answeredPrayer.time, format: 'D, M j Y');
    return GestureDetector(
      onTap: () {
        if (answeredPrayer.prayerItem != null) {
          navigationController.pushContext(
              PageSpec.details(prayerItemId: answeredPrayer.prayerItem!.id));
        }
      },
      child: ListTile(
        title: Text(
          [
            ...answeredPrayer.breadcrumbDescriptions,
            answeredPrayer.description,
          ].join(' / '),
        ),
        subtitle: Text('answered $dateAnswered'),
      ),
    );
  }
}
