class LnurlpCallbackResponseDto {
  final String pr;
  final List<dynamic> routes;

  LnurlpCallbackResponseDto({required this.pr, required this.routes});

  factory LnurlpCallbackResponseDto.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('pr') || !json.containsKey('routes')) {
      throw const FormatException(
          'Missing required fields in LNURLP callback response');
    }

    return LnurlpCallbackResponseDto(
      pr: json['pr'] as String,
      routes: json['routes'] as List<dynamic>,
    );
  }
}
