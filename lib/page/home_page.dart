import 'package:flutter/material.dart';
import 'package:prayer_app/data/root_prayer_item.dart';
import 'package:prayer_app/navigation/navigation_controller.dart';
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

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final navigationController = Provider.of<NavigationController>(context);
    return Scaffold(
      body: Center(
          child: ElevatedButton(
        onPressed: () => navigationController.pushContext(rootPrayerItem),
        child: const Text('Pray'),
      )),
    );
  }
}
