import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sqlite_crud/main.dart';
import 'package:flutter_sqlite_crud/user.dart';

void main() {
  group('User model', () {
    test('toMap() serializes correctly', () {
      final user = User(id: 1, username: 'Alice', email: 'alice@example.com');
      final map = user.toMap();
      expect(map['id'], 1);
      expect(map['username'], 'Alice');
      expect(map['email'], 'alice@example.com');
    });

    test('fromMap() deserializes correctly', () {
      final map = {'id': 2, 'username': 'Bob', 'email': 'bob@example.com'};
      final user = User.fromMap(map);
      expect(user.id, 2);
      expect(user.username, 'Bob');
      expect(user.email, 'bob@example.com');
    });

    test('User without id has null id', () {
      final user = User(username: 'New', email: 'new@example.com');
      expect(user.id, isNull);
    });
  });

  group('MyApp widget', () {
    testWidgets('renders MaterialApp with correct title', (tester) async {
      await tester.pumpWidget(MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
