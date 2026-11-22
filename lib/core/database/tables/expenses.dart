import 'package:drift/drift.dart';

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();

  RealColumn get amount => real()();

  TextColumn get category =>
      text().withDefault(const Constant('Other'))();

  // Nullable  যাতে পুরোনো records নিরাপদে migrate হয়।
  DateTimeColumn get createdAt => dateTime().nullable()();
}