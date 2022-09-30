import 'package:injectable/injectable.dart';

import '../dao/dao.dart';
import 'AppDatabase.dart';

@module
abstract class AppDatabaseBeanDef {
  @preResolve
  @singleton
  Future<AppDatabase> appDatabase() {
    return $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }
}
