import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../core/config/app_config.dart';
import '../../core/providers/app_services.dart';
import '../../core/theme/pages/ai_chat_theme.dart';
import '../../core/theme/getir_style_delivery_ui_spacing.dart';
import '../../core/theme/getir_style_delivery_ui_typography.dart';
import '../../core/utils/format_utils.dart';
import '../../l10n/app_localizations.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _controller = TextEditingController();
  final _messages = <_ChatMessage>[];
  bool _busy = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      _messages.add(
        _ChatMessage(
          text: AppLocalizations.of(context).aiGreeting,
          isUser: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _messages.add(_ChatMessage(text: text.trim(), isUser: true));
    });
    _controller.clear();
    final placeholder = AppLocalizations.of(context).serviceHomePlaceholder;

    try {
      final items = await AppServices.instance.ai.getRecommendations(
        city: AppConfig.defaultCity,
        limit: 5,
      );
      final reply = items.isEmpty
          ? placeholder
          : items
              .map((i) => '• ${i.name} (${formatToman(i.price)})')
              .join('\n');
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
        _busy = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(text: placeholder, isUser: false),
        );
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    final suggestions = [
      l10n.suggestionOrder,
      l10n.suggestionDeals,
      l10n.suggestionSupport,
    ];

    return Scaffold(
      backgroundColor: AiChatTheme.screenBackground,
      appBar: AppBar(
        backgroundColor: AiChatTheme.appBarBackground,
        foregroundColor: AiChatTheme.appBarForeground,
        title: Text(
          l10n.aiAssistant,
          style: GetirStyleDeliveryUiTypography.headlineLg(
            locale,
            color: AiChatTheme.appBarForeground,
          ).copyWith(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AiChatTheme.margin),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isUser
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser
                          ? AiChatTheme.userBubbleBackground
                          : AiChatTheme.aiBubbleBackground,
                      borderRadius: BorderRadius.circular(AiChatTheme.bubbleRadius),
                    ),
                    child: Text(
                      msg.text,
                      style: GetirStyleDeliveryUiTypography.bodyMd(
                        locale,
                        color: msg.isUser
                            ? AiChatTheme.userBubbleForeground
                            : AiChatTheme.aiBubbleForeground,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AiChatTheme.margin),
            child: Row(
              children: suggestions
                  .map(
                    (s) => Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 8),
                      child: ActionChip(
                        label: Text(s),
                        onPressed: _busy ? null : () => _send(s),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AiChatTheme.margin),
            child: Row(
              children: [
                Expanded(
                  child: ShadInput(
                    controller: _controller,
                    placeholder: Text(l10n.aiPlaceholder),
                    onSubmitted: _send,
                  ),
                ),
                const SizedBox(width: GetirStyleDeliveryUiSpacing.stackSm),
                ShadButton(
                  onPressed: _busy ? null : () => _send(_controller.text),
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}
