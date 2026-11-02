
import 'package:drift/drift.dart';

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get category => text()();

  RealColumn get amount => real()();

  IntColumn get month => integer()();

  IntColumn get year => integer()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  // একই মাসে একই Category-তে duplicate budget হবে না।
  @override
  List<Set<Column>> get uniqueKeys => [
    {category, month, year},
  ];
}
