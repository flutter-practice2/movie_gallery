// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i11;

import '../chat/MessageReceivedNotifier.dart' as _i9;
import '../http/MyClient.dart' as _i10;
import '../login/LoginNotifier.dart' as _i18;
import '../mqtt/MyMqttClient.dart' as _i14;
import '../repository/ChatMessageRepository.dart' as _i6;
import '../repository/ChatRepository.dart' as _i8;
import '../repository/dao/ChatDao.dart' as _i4;
import '../repository/dao/ChatMessageDao.dart' as _i5;
import '../repository/dao/dao.dart' as _i7;
import '../repository/dao/UserDao.dart' as _i12;
import '../repository/db/AppDatabase.dart' as _i3;
import '../repository/db/AppDatabaseBeanDef.dart' as _i19;
import '../repository/UserRepository.dart' as _i13;
import '../webrtc/RoomClient.dart' as _i15;
import '../webrtc/RoomListener.dart' as _i16;
import '../webrtc/WebRTCListener.dart' as _i17;
import 'RegisterModule%20.dart' as _i20; // ignore_for_file: unnecessary_lambdas

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
  gh.singleton<_i8.ChatRepository>(_i8.ChatRepository(get<_i7.ChatDao>()));
  gh.singleton<_i9.MessageReceivedNotifier>(_i9.MessageReceivedNotifier());
  gh.singleton<_i10.MyClient>(_i10.MyClient.create());
  await gh.singletonAsync<_i11.SharedPreferences>(() => registerModule.prefs,
      preResolve: true);
  gh.singleton<_i12.UserDao>(_i12.UserDao.userDao(get<_i3.AppDatabase>()));
  gh.singleton<_i13.UserRepository>(
      _i13.UserRepository(get<_i10.MyClient>(), get<_i12.UserDao>()));
  gh.singleton<_i14.MyMqttClient>(_i14.MyMqttClient(
      get<_i11.SharedPreferences>(), get<_i6.ChatMessageRepository>()));
  gh.singleton<_i15.RoomClient>(_i15.RoomClient(get<_i14.MyMqttClient>()));
  gh.singleton<_i16.RoomListener>(
      _i16.RoomListener(get<_i14.MyMqttClient>(), get<_i15.RoomClient>()));
  gh.singleton<_i17.WebRTCListener>(
      _i17.WebRTCListener(get<_i14.MyMqttClient>()));
  gh.singleton<_i18.LoginNotifier>(_i18.LoginNotifier(
      get<_i11.SharedPreferences>(),
      get<_i10.MyClient>(),
      get<_i14.MyMqttClient>()));
  return get;
}

class _$AppDatabaseBeanDef extends _i19.AppDatabaseBeanDef {}

class _$RegisterModule extends _i20.RegisterModule {}
