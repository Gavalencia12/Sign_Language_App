import 'package:flutter/material.dart';

class GoogleLikeBox extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode textFocus;
  final String interpretedText;
  final bool isSpeechListening;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final bool themeProvider;

  const GoogleLikeBox({
    Key? key,
    required this.textController,
    required this.textFocus,
    required this.interpretedText,
    required this.isSpeechListening,
    required this.onChanged,
    required this.onClear,
    required this.themeProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Verificar si el tema es oscuro o claro
    final isDark = themeProvider;

    // Fondo y sombra dependiendo del tema
    final bg = isDark ? Colors.grey[850] : Colors.grey[200];

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.black12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Botón “X” para borrar contenido
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Clear',
              onPressed: interpretedText.isEmpty ? null : onClear,
            ),
          ),

          // Contenedor principal con el campo de texto
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Área de texto editable
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 48, 8),
                  child: TextField(
                    controller: textController,
                    focusNode: textFocus,
                    enabled: !isSpeechListening, // Deshabilitar cuando el micrófono está activo
                    maxLines: null,
                    minLines: 3,
                    keyboardType: TextInputType.multiline,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: 'Escribe aquí...',  // Texto placeholder
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.black.withOpacity(0.55),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    onChanged: onChanged,
                  ),
                ),
              ),

              // Espacio para mostrar emojis si se tiene alguno
              if (interpretedText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '😀', // Aquí se podría agregar el emoji correspondiente
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),

              // Barra inferior con los controles
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  children: [
                    // Micrófono o stop
                    _micButton(),

                    // Si el texto está disponible, mostrar la opción de hablar el texto
                    IconButton(
                      tooltip: 'Speak Text',
                      icon: const Icon(Icons.volume_up),
                      onPressed: interpretedText.isEmpty
                          ? null
                          : () {
                              // Aquí agregamos la función para hablar el texto
                              // _speech.speak(interpretedText);
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Botón de micrófono, dependiendo de si está escuchando o no
  Widget _micButton() {
    return IconButton(
      icon: Icon(isSpeechListening ? Icons.stop_rounded : Icons.mic),
      tooltip: isSpeechListening ? 'Stop Listening' : 'Start Listening',
      onPressed: () {
        // Aquí se puede manejar el comportamiento de comenzar o detener la escucha
        // isSpeechListening ? stopListening() : startListening();
      },
    );
  }
}
