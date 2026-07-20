import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import 'package:permission_handler/permission_handler.dart';

import '../../core/providers/app_services.dart';
import '../../core/theme/getir_style_delivery_ui_colors.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../data/repositories/communications_repository.dart';

const _fa = Locale('fa');

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({
    super.key,
    required this.session,
    required this.peerName,
  });

  final CallSession session;
  final String peerName;

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  lk.Room? _room;
  lk.EventsListener<lk.RoomEvent>? _listener;
  bool _connecting = true;
  bool _muted = false;
  bool _ending = false;
  bool _endedReported = false;
  int _remoteCount = 0;
  String _status = 'در حال اتصال...';

  @override
  void initState() {
    super.initState();
    unawaited(_connect());
  }

  @override
  void dispose() {
    unawaited(_reportEnded());
    unawaited(_listener?.dispose());
    unawaited(_room?.dispose());
    super.dispose();
  }

  Future<void> _connect() async {
    final micReady = await _requestMicrophone();
    if (!micReady) return;

    final room = lk.Room(
      roomOptions: const lk.RoomOptions(adaptiveStream: true, dynacast: true),
    );
    final listener = room.createListener()
      ..on<lk.RoomDisconnectedEvent>((_) {
        if (mounted) setState(() => _status = 'تماس پایان یافت');
      })
      ..on<lk.ParticipantConnectedEvent>((_) => _syncRemoteParticipants())
      ..on<lk.ParticipantDisconnectedEvent>((_) => _syncRemoteParticipants());

    _room = room;
    _listener = listener;

    try {
      await room.connect(
        widget.session.livekitUrl,
        widget.session.token,
        connectOptions: const lk.ConnectOptions(autoSubscribe: true),
      );
      await room.localParticipant?.setMicrophoneEnabled(true);
      if (room.canPlaybackAudio == false) {
        await room.startAudio();
      }
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _remoteCount = room.remoteParticipants.length;
        _status = _remoteCount == 0 ? 'در انتظار اتصال مشتری...' : 'تماس برقرار است';
      });
    } catch (_) {
      await _reportEnded();
      if (!mounted) return;
      setState(() {
        _connecting = false;
        _status = 'اتصال تماس ناموفق بود.';
      });
    }
  }

  Future<bool> _requestMicrophone() async {
    if (kIsWeb) return true;
    final status = await Permission.microphone.request();
    if (status.isGranted) return true;
    if (!mounted) return false;
    setState(() {
      _connecting = false;
      _status = 'برای تماس صوتی، اجازه دسترسی به میکروفون لازم است.';
    });
    return false;
  }

  void _syncRemoteParticipants() {
    final count = _room?.remoteParticipants.length ?? 0;
    if (!mounted) return;
    setState(() {
      _remoteCount = count;
      _status = count == 0 ? 'در انتظار اتصال مشتری...' : 'تماس برقرار است';
    });
  }

  Future<void> _toggleMute() async {
    final participant = _room?.localParticipant;
    if (participant == null) return;
    final nextMuted = !_muted;
    await participant.setMicrophoneEnabled(!nextMuted);
    if (!mounted) return;
    setState(() => _muted = nextMuted);
  }

  Future<void> _leave() async {
    if (_ending) return;
    setState(() => _ending = true);
    await _room?.localParticipant?.setMicrophoneEnabled(false);
    await _room?.disconnect();
    await _reportEnded();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _reportEnded() async {
    if (_endedReported || widget.session.callLogId.isEmpty) return;
    _endedReported = true;
    try {
      await AppServices.instance.communications.endCall(widget.session.callLogId);
    } catch (_) {
      // The media room still closes locally if logging the end fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_ending,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leave());
      },
      child: Scaffold(
        backgroundColor: GetirStyleDeliveryUiColors.background,
        appBar: AppBar(
          backgroundColor: GetirStyleDeliveryUiColors.primary,
          foregroundColor: GetirStyleDeliveryUiColors.onPrimary,
          title: const Text('تماس صوتی'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(GetirStyleDeliveryUiSpacing.marginMobile),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 112,
                  height: 112,
                  decoration: const BoxDecoration(
                    color: GetirStyleDeliveryUiColors.primaryFixed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 48, color: GetirStyleDeliveryUiColors.primary),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.peerName,
                  textAlign: TextAlign.center,
                  style: GetirStyleDeliveryUiTypography.headlineLg(_fa, color: GetirStyleDeliveryUiColors.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: GetirStyleDeliveryUiTypography.bodyMd(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Text(
                  'اتاق: ${widget.session.channelName}',
                  textDirection: TextDirection.ltr,
                  style: GetirStyleDeliveryUiTypography.labelSm(_fa, color: GetirStyleDeliveryUiColors.outline),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundCallButton(
                      icon: _muted ? Icons.mic_off : Icons.mic,
                      label: _muted ? 'بی‌صدا' : 'میکروفون',
                      onPressed: _connecting || _ending ? null : _toggleMute,
                      background: GetirStyleDeliveryUiColors.surfaceContainerHighest,
                      foreground: GetirStyleDeliveryUiColors.onSurface,
                    ),
                    const SizedBox(width: 20),
                    _RoundCallButton(
                      icon: Icons.call_end,
                      label: _remoteCount > 0 ? 'پایان تماس' : 'خروج',
                      onPressed: _ending ? null : _leave,
                      background: GetirStyleDeliveryUiColors.error,
                      foreground: GetirStyleDeliveryUiColors.onError,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundCallButton extends StatelessWidget {
  const _RoundCallButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: onPressed == null ? GetirStyleDeliveryUiColors.surfaceContainer : background,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Icon(icon, color: foreground, size: 28),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GetirStyleDeliveryUiTypography.labelMd(_fa, color: GetirStyleDeliveryUiColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
