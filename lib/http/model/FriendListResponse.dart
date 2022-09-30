import 'User.dart';

class FriendListResponse {
  FriendListResponse({
    this.pageNumber,
    this.pageSize,
    this.total,
    this.list,
  });

  FriendListResponse.fromJson(dynamic json) {
    pageNumber = json['pageNumber'];
    pageSize = json['pageSize'];
    total = json['total'];
    if (json['list'] != null) {
      list = [];
      json['list'].forEach((v) {
        list?.add(User.fromJson(v));
      });
    }
  }

  int? pageNumber;
  int? pageSize;
  int? total;
  List<User>? list;

  FriendListResponse copyWith({
    int? pageNumber,
    int? pageSize,
    int? total,
    List<User>? user,
  }) =>
      FriendListResponse(
        pageNumber: pageNumber ?? this.pageNumber,
        pageSize: pageSize ?? this.pageSize,
        total: total ?? this.total,
        list: user ?? this.list,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['pageNumber'] = pageNumber;
    map['pageSize'] = pageSize;
    map['total'] = total;
    if (list != null) {
      map['list'] = list?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
