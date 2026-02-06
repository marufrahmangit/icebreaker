import 'dart:math';
import 'package:flutter/material.dart';

/* ============================================================
   CHAT DIALOG (no emergency button)
   Dummy user sends multiple lines of messages:
   1. "Hi 👋"
   2. "Nice to meet you!"
   3. "Did you want to hang out?"
   ============================================================ */
class ChatDialog extends StatefulWidget {
  final String userName;
  final String? banner;
  final VoidCallback onClose;

  const ChatDialog({
    super.key,
    required this.userName,
    required this.onClose,
    this.banner,
  });

  @override
  State<ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<ChatDialog> {
  final TextEditingController _controller = TextEditingController();
  final List<_Msg> _messages = <_Msg>[];

  // The sequence of dummy replies
  static const List<String> _dummyReplies = [
    "Hi 👋",
    "Nice to meet you!",
    "Did you want to hang out?",
  ];
  int _replyIndex = 0;

  @override
  void initState() {
    super.initState();
    // Seed the first message from the other user
    _messages.add(const _Msg(fromMe: false, text: "Hi 👋"));
    _replyIndex = 1; // Next reply starts at index 1
  }

  void _send() {
    final txt = _controller.text.trim();
    if (txt.isEmpty) return;

    setState(() {
      _messages.add(_Msg(fromMe: true, text: txt));

      // Send next dummy reply from the predefined sequence
      if (_replyIndex < _dummyReplies.length) {
        _messages.add(_Msg(fromMe: false, text: _dummyReplies[_replyIndex]));
        _replyIndex++;
      } else {
        // After all predefined replies are used, cycle through them
        final cycled = _dummyReplies[_replyIndex % _dummyReplies.length];
        _messages.add(_Msg(fromMe: false, text: cycled));
        _replyIndex++;
      }
    });

    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      backgroundColor: const Color(0xFFE9F4FE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      child: SizedBox(
        width: 370,
        height: min(MediaQuery.of(context).size.height * 0.62, 520),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Chat with ${widget.userName}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  if (widget.banner != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(widget.banner!, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, i) {
                        final m = _messages[i];
                        return Align(
                          alignment: m.fromMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: const BoxConstraints(maxWidth: 280),
                            decoration: BoxDecoration(
                              color: m.fromMe ? const Color(0xFF7C3AED) : const Color(0xFFF59E42),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(blurRadius: 4, color: Color(0x22000000), offset: Offset(0, 1)),
                              ],
                            ),
                            child: Text(
                              m.text,
                              style: TextStyle(
                                color: m.fromMe ? Colors.white : const Color(0xFF252525),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _send,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Send", style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 10,
              child: IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: Color(0xFF7C3AED)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final bool fromMe;
  final String text;
  const _Msg({required this.fromMe, required this.text});
}