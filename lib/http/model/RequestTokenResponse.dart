class RequestTokenResponse{
  String? putUrl;
  String? getUrl;

  RequestTokenResponse({
    this.putUrl,
    this.getUrl,
  });

  factory RequestTokenResponse.fromJson(Map<String, dynamic> json) {
    return RequestTokenResponse(
      putUrl: json["putUrl"],
      getUrl: json["getUrl"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "putUrl": this.putUrl,
      "getUrl": this.getUrl,
    };
  }


}
