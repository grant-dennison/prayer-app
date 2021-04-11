import 'package:hive/hive.dart';

class MockLazyBox<T> implements LazyBox<T> {
  final Map<String, T> backing = {};

  @override
  Future<int> add(T value) {
    throw UnimplementedError();
  }

  @override
  Future<Iterable<int>> addAll(Iterable<T> values) {
    throw UnimplementedError();
  }

  @override
  Future<int> clear() {
    throw UnimplementedError();
  }

  @override
  Future<void> close() {
    throw UnimplementedError();
  }

  @override
  Future<void> compact() {
    throw UnimplementedError();
  }

  @override
  bool containsKey(key) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(key) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll(Iterable keys) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAt(int index) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFromDisk() {
    throw UnimplementedError();
  }

  @override
  Future<T?> get(key, {T? defaultValue}) async {
    return backing[key] ?? defaultValue;
  }

  @override
  Future<T?> getAt(int index) {
    throw UnimplementedError();
  }

  @override
  bool get isEmpty => throw UnimplementedError();

  @override
  bool get isNotEmpty => throw UnimplementedError();

  @override
  bool get isOpen => throw UnimplementedError();

  @override
  dynamic keyAt(int index) {
    throw UnimplementedError();
  }

  @override
  Iterable get keys => throw UnimplementedError();

  @override
  bool get lazy => throw UnimplementedError();

  @override
  int get length => throw UnimplementedError();

  @override
  String get name => throw UnimplementedError();

  @override
  String? get path => throw UnimplementedError();

  @override
  Future<void> put(key, T value) async {
    backing[key] = value;
  }

  @override
  Future<void> putAll(Map<dynamic, T> entries) {
    throw UnimplementedError();
  }

  @override
  Future<void> putAt(int index, T value) {
    throw UnimplementedError();
  }

  @override
  Stream<BoxEvent> watch({key}) {
    throw UnimplementedError();
  }
}
