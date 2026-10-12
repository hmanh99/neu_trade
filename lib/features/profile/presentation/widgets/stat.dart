import 'package:flutter/material.dart';

class Stat extends StatelessWidget {
  const Stat({super.key, required this.value, required this.label});

  final String value, label;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13, color: Colors.white70),
      ),
    ],
  );
}
