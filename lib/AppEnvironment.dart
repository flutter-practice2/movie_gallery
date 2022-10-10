
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment{

  static get envFile => kReleaseMode? '.env.production':'.env.development';

  static get apiBaseUrl =>  dotenv.env['apiBaseUrl'];
}
