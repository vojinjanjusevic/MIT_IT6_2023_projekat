import 'package:flutter/material.dart';

class SpecChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const SpecChip({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
    );
  }
}