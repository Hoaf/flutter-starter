import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class BaseResponse {
  @JsonKey(name: 'isSuccess')
  bool? isSuccess;

  @JsonKey(name: 'errorMessage')
  String? errorMessage;

  @JsonKey(name: 'errorCode')
  String? errorCode;

  @JsonKey(name: 'responseCode')
  int? responseCode;

  BaseResponse({required this.isSuccess});

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    return BaseResponse(
      isSuccess: json['isSuccess'] as bool?,
    )
    ..errorMessage = json['errorMessage'] as String?
    ..responseCode = json['responseCode'] as int?
    ..errorCode = json['errorCode'] as String?;
  }
}