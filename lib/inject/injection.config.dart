// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i10;

import '../http/MyClient.dart' as _i9;
import '../login/LoginNotifier.dart' as _i17;
import '../mqtt/MyMqttClient.dart' as _i13;
import '../repository/ChatMessageRepository.dart' as _i6;
import '../repository/ChatRepository.dart' as _i8;
import '../repository/UserRepository.dart' as _i12;
import '../repository/dao/ChatDao.dart' as _i4;
import '../repository/dao/ChatMessageDao.dart' as _i5;
import '../repository/dao/UserDao.dart' as _i11;
import '../repository/dao/dao.dart' as _i7;
import '../repository/db/AppDatabase.dart' as _i3;
import '../repository/db/AppDatabaseBeanDef.dart' as _i18;
import '../webrtc/RoomClient.dart' as _i14;
import '../webrtc/RoomListener.dart' as _i15;
import '../webrtc/WebRTCListener.dart' as _i16;
import 'RegisterModule%20.dart' as _i19; // ignore_for_file: unnecessary_lambdas

// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of provided dependencies inside of [GetIt]
Future<_i1.GetIt> $initGetIt(_i1.GetIt get,
    {String? environment, _i2.EnvironmentFilter? environmentFilter}) async {
  final gh = _i2.GetItHelper(get, environment, environmentFilter);
  final appDatabaseBeanDef = _$AppDatabaseBeanDef();
  final registerModule = _$RegisterModule();
  await gh.singletonAsync<_i3.AppDatabase>(
      () => appDatabaseBeanDef.appDatabase(),
      preResolve: true);
  gh.singleton<_i4.ChatDao>(_i4.ChatDao.chatDao(get<_i3.AppDatabase>()));
  gh.singleton<_i5.ChatMessageDao>(
      _i5.ChatMessageDao.chatMessageDao(get<_i3.AppDatabase>()));
  gh.singleton<_i6.ChatMessageRepository>(
      _i6.ChatMessageRepository(get<_i7.ChatMessageDao>()));
  gh.singleton<_i8.ChatRepository>(
      _i8.ChatRepository(get<_i7.ChatDao>(), get<_i7.ChatMessageDao>()));
  gh.singleton<_i9.MyClient>(_i9.MyClient.create());
  await gh.singletonAsync<_i10.SharedPreferences>(() => registerModule.prefs,
      preResolve: true);
  gh.singleton<_i11.UserDao>(_i11.UserDao.userDao(get<_i3.AppDatabase>()));
  gh.singleton<_i12.UserRepository>(
      _i12.UserRepository(get<_i9.MyClient>(), get<_i11.UserDao>()));
  gh.singleton<_i13.MyMqttClient>(_i13.MyMqttClient(
      get<_i10.SharedPreferences>(), get<_i6.ChatMessageRepository>()));
  gh.singleton<_i14.RoomClient>(_i14.RoomClient(get<_i13.MyMqttClient>()));
  gh.singleton<_i15.RoomListener>(
      _i15.RoomListener(get<_i13.MyMqttClient>(), get<_i14.RoomClient>()));
  gh.singleton<_i16.WebRTCListener>(
      _i16.WebRTCListener(get<_i13.MyMqttClient>()));
  gh.singleton<_i17.LoginNotifier>(_i17.LoginNotifier(
      get<_i10.SharedPreferences>(),
      get<_i9.MyClient>(),
      get<_i13.MyMqttClient>()));
  return get;
}

class _$AppDatabaseBeanDef extends _i18.AppDatabaseBeanDef {}

class _$RegisterModule extends _i19.RegisterModule {}
