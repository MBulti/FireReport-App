import 'package:flutter/material.dart';

typedef OnSecondaryButtonClick = void Function();

class ExpandableFloatinActionButton extends StatefulWidget {
  final Icon mainButtonIcon;
  final Icon? mainButtonExpandedIcon;
  final List<SecondaryExpandedButton> secondaryButtons;

  const ExpandableFloatinActionButton({
    super.key,
    required this.mainButtonIcon,
    this.mainButtonExpandedIcon,
    required this.secondaryButtons,
  });

  @override
  State<ExpandableFloatinActionButton> createState() => _ExpandableFloatinActionButtonState();
}

class _ExpandableFloatinActionButtonState extends State<ExpandableFloatinActionButton> {
  bool _isExpanded = false;

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Secondary buttons with labels
        if (_isExpanded)
          ...widget.secondaryButtons.asMap().entries.map((mapEntry) {
            final button = mapEntry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(button.label, style: const TextStyle(fontSize: 16.0)),
                  ),
                  FloatingActionButton(
                    heroTag: mapEntry.key,
                    child: button.icon,
                    onPressed: () {
                      button.onPressed?.call();
                      _toggle();
                    },
                  ),
                ],
              ),
            );
          }),
        // Main button
        FloatingActionButton(
          onPressed: _toggle,
          child: _isExpanded
              ? widget.mainButtonExpandedIcon ?? const Icon(Icons.close)
              : widget.mainButtonIcon,
        ),
      ],
    );
  }
}

class SecondaryExpandedButton {
  final Icon icon;
  final String label; // Label text to display next to the button
  final Color? backgroundColor;
  final OnSecondaryButtonClick? onPressed;

  const SecondaryExpandedButton({
    required this.icon,
    required this.label,
    this.backgroundColor,
    this.onPressed,
  });
}