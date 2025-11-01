import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/theme/theme.dart';

class TextFields extends StatefulWidget {
  final String label;
  final IconData? icon;

  final TextEditingController? controller;
  final bool obscureText;
  final bool showVisibilityToggle; // para mostrar botón ojo
  final VoidCallback? onToggleVisibility;

  const TextFields({Key? key, this.label = 'Escribe aquí', this.icon, this.controller,
    this.obscureText = false,
    this.showVisibilityToggle = false,
    this.onToggleVisibility,}) : super(key: key);

  @override
  _TextFieldsState createState() => _TextFieldsState();
}

class _TextFieldsState extends State<TextFields> {
  String texto = '';

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        focusedBorder: OutlineInputBorder( //erespd
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: AppColors.lightPrimary, width: 2),
    ),
      suffixIcon: widget.showVisibilityToggle
            ? IconButton(
                icon: Icon(
                  widget.obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: widget.onToggleVisibility,
              )
            : null,
      ),
      
      onChanged: (value) {
        setState(() {
          texto = value;
        });
        print('Texto ingresado: $texto');
      },
    );
  }
}
