import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/service/speech_io_service.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';

//
// Pantalla: INTÉRPRETE (voz <-> texto) para SpeakHands
// ---------------------------------------------------
// - Provee entrada por voz (Speech-to-Text) y lectura en voz alta (Text-to-Speech).
// - Incluye contador de caracteres, botón para limpiar texto y alternancia mic/stop.

class InterpreterScreen extends StatefulWidget {
  const InterpreterScreen({super.key});

  @override
  State<InterpreterScreen> createState() => _InterpreterScreenState();
  
  // Límite de caracteres mostrado en el contador
  static const int _charLimit = 5000;
}

class _InterpreterScreenState extends State<InterpreterScreen> {
  
  // Servicio unificado para STT (speech_to_text) + TTS (flutter_tts)
  final SpeechIOService _speech = SpeechIOService();

  // Texto interpretado (se completa con STT o con tu pipeline LSM->texto)
  String _interpretedText = '';   

  // Flags de estado
  bool _ready = false;             // STT ya inicializado y listo
  bool _readingPreset = false;     // leyendo un texto predeterminado

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Inicializa STT + TTS en español de México (ajústalo a tu necesidad)
      await _speech.init(sttLocale: 'es-MX', ttsLocale: 'es-MX');
      if (!mounted) return;
      setState(() => _ready = _speech.sttReady);

      // Mensaje de bienvenida por voz si el usuario tiene la salida habilitada
      final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
      if (speakOn) {
        final loc = AppLocalizations.of(context)!;
        final lc = Localizations.localeOf(context).languageCode;
        await _speech.speak(loc.learn_info, languageCode: lc);
      }
    });
  }

  @override
  void dispose() {
    // Libera recursos de STT/TTS al cerrar la pantalla
    _speech.dispose();
    super.dispose();
  }

  /// Inicia el reconocimiento de voz.
  /// - Actualiza _interpretedText en tiempo real (partialResults).
  /// - Si el resultado es final y el usuario activó “voz”, lo lee en voz alta.
  Future<void> _startStt() async {
    if (!_ready || _speech.isListening) return;
    await _speech.startListening(
      localeId: 'es-MX',
      onResult: (text, isFinal) async {
        setState(() {
          _interpretedText = text.length > InterpreterScreen._charLimit
          ? text.substring(0, InterpreterScreen._charLimit)
          : text;
        });
        
        // Si quieres que al terminar hable el resultado:
        final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
        if (isFinal && speakOn && _interpretedText.isNotEmpty) {
          await _speech.speak(_interpretedText);
        }
      },
    );
  }

  /// Detiene el reconocimiento de voz (si está activo).
  Future<void> _stopStt() => _speech.stopListening();

  /// Ejemplo de lectura de un texto predeterminado (para pruebas)
  Future<void> _speakPreset() async {
    if (_readingPreset) return;
    setState(() => _readingPreset = true);
    final loc = AppLocalizations.of(context)!;
    await _speech.speak(loc.interpreter_screen_title); // ejemplo: lee un texto predeterminado
    if (mounted) setState(() => _readingPreset = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;
    final speakOn = Provider.of<SpeechProvider>(context).enabled;

    return Scaffold(
      appBar: CustomAppBar(title: loc.interpreter_screen_title),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isPortrait = orientation == Orientation.portrait;
          
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isPortrait
              ? Column(children: _buildContent(context, themeProvider, loc, speakOn))
              
              // Diseño horizontal: cuadro a la izquierda y contenido a la derecha
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: _buildCameraPreview(context, loc), // placeholder de cámara (si luego se usas)
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildContent(context, themeProvider, loc, speakOn, excludeCamera: true),
                      ),
                    )
                  ],
                ),
            ),
          );
        },
      ),
    );
  }

  /// Construye el contenido adaptable de la pantalla
  List<Widget> _buildContent(
    BuildContext context,
    ThemeProvider themeProvider,
    AppLocalizations loc,
    bool speakOn, {
      bool excludeCamera = false,
    }) {
      return [
      if (!excludeCamera) ...[
        Text(
          loc.let_your_sign_be_heard,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        
        const SizedBox(height: 10),
        
        // Cuadro que crece hasta ~30% de alto de pantalla
        Flexible(
          fit: FlexFit.loose,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.30,
              minHeight: 120, // evita que se colapse
            ),
            
            child: _googleLikeBox(themeProvider, loc, speakOn),
          ),
        ),
        
        const SizedBox(height: 16),

        // Placeholder de “preview” (si después agregas cámara o visualización)
        AspectRatio(
          aspectRatio: 1,
          child: _buildCameraPreview(context, loc),
        ),
        
        const SizedBox(height: 16),
      ],
    ];
  }

  /// Widget con el cuadro de texto + barra inferior (mic/tts/contador) + botón “X”.
  Widget _googleLikeBox(
    ThemeProvider themeProvider,
    AppLocalizations loc,
    bool speakOn,
    ) 
    {
      final theme = Theme.of(context);

      // Colores coherentes con el tema actual
      final Color baseTextColor = 
        theme.textTheme.bodyLarge?.color ?? 
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);
      

      // Placeholder más claro que el texto real
      final Color placeholderColor = baseTextColor.withOpacity(0.55);
      final isDark = themeProvider.isDarkMode;
      final bg = isDark ? AppTheme.darkSecondary : AppTheme.lightSecondary;

      final isEmpty = _interpretedText.trim().isEmpty;
      
      return Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
          border: Border.all(color: Colors.black12),
        ),
        
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Botón “X” para vaciar el texto
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                tooltip: loc.clear,
                onPressed: isEmpty ? null : () {
                  setState(() => _interpretedText = '');
                  _speech.stopSpeak();
                  _speech.stopListening();
                },
              ),
            ),
            
            // Contenido principal
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Área de texto (arriba)
                Expanded(
                  child: Container(
                    width: double.infinity,                 
                    alignment: Alignment.topLeft, // esquina superior izquierda 
                    padding: const EdgeInsets.fromLTRB(16, 16, 48, 8), // deja espacio para la “X”
                    child: SingleChildScrollView(
                      child: SelectableText(
                        isEmpty ? loc.translation : _interpretedText,
                        textAlign: TextAlign.left,          
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: isEmpty ? FontWeight.w500 : FontWeight.w600,
                          color: isEmpty ? placeholderColor : baseTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Barra inferior (botones + contador)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.black12)),
                  ),

                  child: Row(
                    children: [
                      // Botón de dictado: alterna Mic <-> Stop con animación + halo
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                        child: _speech.isListening
                        ? Container(
                          key: const ValueKey('stop'),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 18,
                                spreadRadius: 2,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                              ),
                            ],
                          ),
                          
                          child: Material(
                            color: Theme.of(context).colorScheme.primary,
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: 'Detener grabación',
                              icon: const Icon(Icons.stop_rounded, color: Colors.white),
                              onPressed: () async {
                                await _stopStt();
                                if (mounted) setState(() {}); // refresca el ícono
                              },
                            ),
                          ),
                        )
                        
                        : Material(
                          key: const ValueKey('mic'),
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Dictar',
                            icon: const Icon(Icons.mic),
                            onPressed: !_ready ? null : () async {
                              await _startStt();
                              if (mounted) setState(() {}); // refresca el ícono
                              },
                          ),
                        ),
                      ),
                      
                      // Botón: leer en voz alta el contenido actual
                      IconButton(
                        tooltip: loc.speakText,
                        icon: const Icon(Icons.volume_up),
                        onPressed: _interpretedText.isEmpty ? null : () async {
                          if (speakOn) {
                            await _speech.speak(_interpretedText);
                          }
                        },
                      ),
                      
                      const Spacer(),

                      // Contador de caracteres
                      Text(
                        '${_interpretedText.length} / ${InterpreterScreen._charLimit}',
                        style: TextStyle(
                          color: baseTextColor.withOpacity(0.55),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
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
    
    /// Placeholder para el área de “preview” (p.ej. cámara/visualización futura).
    /// Por ahora muestra solo un contenedor gris con borde redondeado.
    Widget _buildCameraPreview(BuildContext context, AppLocalizations loc) {
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.grey[300]),
          ),
        ],
      );
    }
  }
