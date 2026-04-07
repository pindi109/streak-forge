
import 'package:flutter/material.dart';

class EmojiPickerModal extends StatelessWidget {
  const EmojiPickerModal({super.key});

  static const List<Map<String, dynamic>> _emojiCategories = [
    {
      'title': 'Health & Fitness',
      'emojis': ['🏃', '💪', '🧘', '🚴', '🏊', '🥗', '💊', '🩺', '🫀', '🦷'],
    },
    {
      'title': 'Mindfulness',
      'emojis': ['🧠', '🌅', '🌙', '☀️', '🌿', '🌸', '✨', '🔮', '🕯️', '🌊'],
    },
    {
      'title': 'Productivity',
      'emojis': ['📚', '✍️', '💻', '📝', '🎯', '⏰', '📊', '💡', '🗓️', '📌'],
    },
    {
      'title': 'Habits',
      'emojis': ['✅', '🔥', '⭐', '🏆', '💎', '🎖️', '🚀', '💯', '🎯', '🏅'],
    },
    {
      'title': 'Lifestyle',
      'emojis': ['🌍', '🌱', '💰', '🤝', '🎵', '🎨', '📸', '🍎', '🥛', '😴'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Color(0xFF18181B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Choose Emoji',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFA1A1AA)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF27272A), height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _emojiCategories.length,
              itemBuilder: (context, index) {
                final category = _emojiCategories[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['title'],
                      style: const TextStyle(
                        color: Color(0xFFA1A1AA),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (category['emojis'] as List<String>)
                          .map((emoji) => GestureDetector(
                                onTap: () => Navigator.pop(context, emoji),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF27272A),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style:
                                          const TextStyle(fontSize: 24),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}