import 'package:SaktoSpend/app/app.dart';
import 'package:SaktoSpend/data/db/db.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const shouldSeedDemoData = bool.fromEnvironment(
    'SEED_DEMO_DATA',
    defaultValue: false,
  );

  if (shouldSeedDemoData) {
    final database = AppDatabase();
    try {
      await DemoDataSeeder.seed(database: database, clearExisting: true);
    } finally {
      await database.close();
    }
  }

  runApp(const ProviderScope(child: SaktoSpendApp()));
}
