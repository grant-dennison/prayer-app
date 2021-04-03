import 'package:flutter/cupertino.dart';
import 'package:prayer_app/model/prayer_item.dart';

abstract class NavigationController implements ChangeNotifier {
  void toggleDetails(bool? show);
  void popContext();
  void pushContext(PrayerItem targetPrayerItem);
}
