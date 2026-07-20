import '../../core/network/api_client.dart';

class CallSession {
  const CallSession({
    required this.token,
    required this.channelName,
    required this.livekitUrl,
    required this.callLogId,
  });

  final String token;
  final String channelName;
  final String livekitUrl;
  final String callLogId;

  factory CallSession.fromJson(Map<String, dynamic> json) => CallSession(
        token: json['token'] as String? ?? '',
        channelName: json['channel_name'] as String? ?? '',
        livekitUrl: json['livekit_url'] as String? ?? '',
        callLogId: json['call_log_id'] as String? ?? '',
      );
}

class CommunicationsRepository {
  CommunicationsRepository(this._client);

  final ApiClient _client;

  Future<CallSession> initiateOrderCall(String orderId) async {
    final resp = await _client.dio.post(
      '/communications/call/initiate/',
      data: {
        'order_id': orderId,
        'consent_acknowledged': true,
      },
    );
    return CallSession.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> endCall(String callLogId) async {
    await _client.dio.post(
      '/communications/call/end/',
      data: {'call_log_id': callLogId},
    );
  }
}
