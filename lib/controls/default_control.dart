import 'package:flutter/material.dart';

class DefaultDivider extends StatelessWidget {
  const DefaultDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.inverseSurface,
    );
  }
}

class DefaultIcon extends StatelessWidget {
  final IconData icon;
  const DefaultIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: Theme.of(context).colorScheme.inverseSurface);
  }
}