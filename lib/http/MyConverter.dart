import 'dart:async';
import 'dart:convert';
import 'package:chopper/chopper.dart';

import 'model/User.dart';
import 'model/UserGeoLocationSearchNearbyResponse.dart';

@deprecated
class MyConverter extends JsonConverter {
  @override
  Request encodeJson(Request request) {
    final String? contentType = request.headers[contentTypeKey];

    return (contentType?.contains(jsonHeaders) ?? false)
        ? request.copyWith(body: json.encode(request.body))
        : request;
  }

  @override
  FutureOr<Response> decodeJson<BodyType, InnerType>(Response response) async {
    final List<String> supportedContentTypes = [jsonHeaders, jsonApiHeaders];

    final String? contentType = response.headers[contentTypeKey];
    var body = response.body;

    if (supportedContentTypes.contains(contentType)) {
      body = utf8.decode(response.bodyBytes);
    }

    body = await tryDecodeJson(body);
    if (isTypeOf<BodyType, Iterable<InnerType>>()) {
      body = body.cast<InnerType>();
    } else if (isTypeOf<BodyType, Map<String, InnerType>>()) {
      body = body.cast<String, InnerType>();
    } //my codes:
    else if (isTypeOf<BodyType, UserGeoLocationSearchNearbyResponse>()) {

      body = UserGeoLocationSearchNearbyResponse.fromJson(body);
    }

    return response.copyWith<BodyType>(body: body);
  }
}
