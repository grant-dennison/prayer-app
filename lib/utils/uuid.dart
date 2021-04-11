import 'dart:convert';

import 'package:uuid/uuid.dart';

String genUuid() {
  final bytes = List.filled(16, 0);
  const u = Uuid();
  u.v4buffer(bytes);
  return base64.encode(bytes);
}
