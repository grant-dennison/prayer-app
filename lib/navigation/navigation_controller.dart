import 'package:flutter/foundation.dart';

import 'page_spec.dart';

abstract class NavigationController implements ChangeNotifier {
  void popContext();
  void pushContext(PageSpec pageSpec);
}
