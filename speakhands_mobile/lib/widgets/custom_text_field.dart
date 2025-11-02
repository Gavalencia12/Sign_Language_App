import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType keyboardType;
  final bool showClearButton;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
    this.keyboardType = TextInputType.text,
    this.showClearButton = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late final FocusNode _focusNode;
  bool _focused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocus);
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_handleText);
  }

  void _handleFocus() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  void _handleText() {
    final nowHasText = widget.controller.text.isNotEmpty;
    if (nowHasText != _hasText) {
      setState(() => _hasText = nowHasText);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    widget.controller.removeListener(_handleText);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Colores según estado/tema
    final baseBorder = theme.colorScheme.outlineVariant.withOpacity(0.45);
    final activeBorder = theme.colorScheme.primary;
    final borderColor = _focused ? activeBorder : baseBorder;

    final baseFill = theme.colorScheme.surface;
    final activeFill = theme.colorScheme.surfaceContainerHighest; // Material 3
    final fillColor = _focused || _hasText ? activeFill : baseFill;

    final boxShadow = _focused
        ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.18),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ]
        : [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: _focused ? 1.6 : 1.0),
        boxShadow: boxShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4), // espacio para iconos
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        keyboardType: widget.keyboardType,
        decoration: InputDecoration(
          // Deja que el contenedor maneje border/fill
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          labelText: widget.label,
          // label animará su posición con el foco automáticamente
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: _focused
                      ? theme.colorScheme.primary
                      : theme.iconTheme.color?.withOpacity(0.8),
                )
              : null,
          suffixIcon: (widget.showClearButton && _hasText)
              ? IconButton(
                  tooltip: 'Limpiar',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                    // Mantiene el foco y forzamos el estado visual
                    setState(() => _hasText = false);
                  },
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
      ),
    );
  }
}
