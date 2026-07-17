import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final bool isCollapsed;
  final VoidCallback onMenuPressed;

  const AppHeader({
    super.key,
    required this.title,
    required this.isCollapsed,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuPressed,
            icon: const Icon(Icons.menu),
          ),

          const SizedBox(width: 10),

          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          const CircleAvatar(
            child: Icon(Icons.person),
          ),

          const SizedBox(width: 12),

          const Text("Admin"),
        ],
      ),
    );
  }
}