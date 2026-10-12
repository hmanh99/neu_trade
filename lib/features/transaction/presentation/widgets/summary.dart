import 'package:flutter/material.dart';

class Summary extends StatelessWidget {
  const Summary({super.key, required this.value, required this.label});

  final String value, label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: Colors.blue,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
    ],
  );
}
