// widgets/draggable_fab.dart (MODIFICADO)
import 'package:flutter/material.dart';
import 'package:speakhands_mobile/screens/interpreter/widgets/carrusel_modal.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';

class DraggableFAB extends StatefulWidget {
  final String storageKey;
  final double initialTop;
  final double initialLeft;
  final BoxConstraints constraints;
  final VoidCallback onPressed; 

  const DraggableFAB({
    super.key,
    required this.storageKey,
    required this.initialTop,
    required this.initialLeft,
    required this.constraints, 
    required this.onPressed,
  });

  @override
  _DraggableFABState createState() => _DraggableFABState();
}

class _DraggableFABState extends State<DraggableFAB> {
  late double top;
  late double left;
  final double buttonSize = 40.0;

  @override
  void initState() {
    super.initState();
    top = widget.initialTop;
    left = widget.initialLeft;
  }

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.text(context);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            left += details.delta.dx;
            top += details.delta.dy;

            if (left < 0) left = 0;
            if (top < 0) top = 0;
            if (left > widget.constraints.maxWidth - buttonSize) left = widget.constraints.maxWidth - buttonSize;
            if (top > widget.constraints.maxHeight - buttonSize) top = widget.constraints.maxHeight - buttonSize;
          });
        },
        child: SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: FloatingActionButton(
            onPressed: widget.onPressed, 
            heroTag: widget.storageKey,
            child: Icon(Icons.info_outline, color: textColor,fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

