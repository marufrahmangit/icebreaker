import 'package:flutter/material.dart';

class ChatMessage {
  const ChatMessage(this.fromMe, this.text);
  final bool fromMe;
  final String text;
}

class ChatModal extends StatefulWidget {
  const ChatModal({
    super.key,
    required this.name,
    required this.onClose,
    required this.initialDraft,
    required this.onDraftChanged,
  });

  final String name;
  final VoidCallback onClose;
  final String initialDraft;
  final ValueChanged<String> onDraftChanged;

  @override
  State<ChatModal> createState() => _ChatModalState();
}

class _ChatModalState extends State<ChatModal> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialDraft;
    _controller.addListener(() => widget.onDraftChanged(_controller.text));
  }

  @override
  void dispose() {
    _scroll.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;

    setState(() {
      _messages
        ..add(ChatMessage(true, txt))
        ..add(const ChatMessage(false, 'Nice to meet you!'));
    });

    _controller.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.14),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // absorb
            child: Container(
              width: MediaQuery.of(context).size.width * 0.94,
              constraints: const BoxConstraints(maxWidth: 370, minWidth: 210, minHeight: 220, maxHeight: 420),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFE9F4FE),
                borderRadius: BorderRadius.circular(19),
                boxShadow: [BoxShadow(blurRadius: 48, color: Colors.black.withOpacity(0.10), offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Chat with ${widget.name}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close, color: Color(0xFF7C3AED)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scroll,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _messages.map((m) {
                          final bubbleColor = m.fromMe ? const Color(0xFF7C3AED) : const Color(0xFFF59E42);
                          final textColor = m.fromMe ? Colors.white : const Color(0xFF252525);
                          final align = m.fromMe ? Alignment.centerRight : Alignment.centerLeft;
                          return Align(
                            alignment: align,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              constraints: const BoxConstraints(maxWidth: 290),
                              decoration: BoxDecoration(
                                color: bubbleColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(m.text, style: TextStyle(color: textColor, height: 1.3)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _send,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        child: const Text('Send', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
