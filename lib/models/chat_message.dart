class ChatMessage {
  final String text;
  final bool isMine;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isMine,
    required this.timestamp,
  });
}
