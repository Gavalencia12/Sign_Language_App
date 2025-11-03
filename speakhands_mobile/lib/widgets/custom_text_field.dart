import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

// ### Features:
// - Fully theme-aware (light/dark).
// - Optional prefix icon and clear button.
// - Supports read-only mode.
// - Integrates custom callbacks for change and submit events.
class CustomTextField extends StatefulWidget {
  // Controller that manages the text content.
  final TextEditingController controller;

  // Label text displayed inside the field.
  final String label;

  // Optional leading icon (e.g. a search or person icon).
  final IconData? icon;

  // Triggered every time the text changes.
  final ValueChanged<String>? onChanged;

  // Triggered when the user submits the input (presses Enter).
  final ValueChanged<String>? onSubmitted;

  // If `true`, disables typing and makes the field read-only.
  final bool readOnly;

  // Optional callback for tapping on the text field (useful with read-only).
  final VoidCallback? onTap;

  // Determines the keyboard layout (text, number, email, etc.).
  final TextInputType keyboardType;

  // Whether to show a clear (“X”) button when text is present.
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

  // Updates the visual state when the field gains or loses focus.
  void _handleFocus() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  // Updates the clear button visibility based on text presence.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // === Dynamic Colors ===
    final Color borderColor =
        _focused
            ? AppColors.primary(context)
            : (isDark
                ? Colors.white.withOpacity(0.25)
                : Colors.black.withOpacity(0.15));

    final Color fillColor =
        _focused
            ? AppColors.surface(context).withOpacity(isDark ? 0.35 : 0.8)
            : AppColors.surface(context).withOpacity(isDark ? 0.2 : 0.6);

    final Color iconColor =
        _focused ? AppColors.primary(context) : AppColors.textMuted(context);

    // === Dynamic Shadows ===
    final boxShadow =
        _focused
            ? [
              BoxShadow(
                color: AppColors.primary(context).withOpacity(0.25),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 5),
              ),
            ]
            : [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ];

    // === Main Field ===
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: _focused ? 1.5 : 1.0),
        boxShadow: boxShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        keyboardType: widget.keyboardType,
        style: TextStyle(color: AppColors.text(context), fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: widget.label,
          labelStyle: TextStyle(
            color:
                _focused
                    ? AppColors.primary(context)
                    : AppColors.textMuted(context),
            fontWeight: FontWeight.w500,
          ),

          // === Optional leading icon ===
          prefixIcon:
              widget.icon != null ? Icon(widget.icon, color: iconColor) : null,

          // === Clear button (visible only when text is present) ===
          suffixIcon:
              (widget.showClearButton && _hasText)
                  ? IconButton(
                    tooltip: 'Limpiar',
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textMuted(context),
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged?.call('');
                      setState(() => _hasText = false);
                    },
                  )
                  : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
