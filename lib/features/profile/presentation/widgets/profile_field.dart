import 'package:flutter/material.dart';

class ProfileField extends StatelessWidget {
  const ProfileField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(label),
    subtitle: Text(value.trim().isEmpty ? 'Chưa cập nhật' : value),
  );
}
