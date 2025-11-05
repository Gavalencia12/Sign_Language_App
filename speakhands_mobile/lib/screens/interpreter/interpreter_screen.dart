import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/theme/text_styles.dart';
import 'package:video_player/video_player.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart'; // Módulo de barra de app
import 'package:speakhands_mobile/widgets/custom_text_field.dart'; // Módulo de campo de texto personalizado
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'services/interpreter_speech_service.dart';
import 'widgets/interpreter_widgets.dart';

class InterpreterScreen extends StatefulWidget {
  const InterpreterScreen({super.key});

  @override
  State<InterpreterScreen> createState() => _InterpreterScreenState();

  static const int _charLimit = 1000;
}

class _InterpreterScreenState extends State<InterpreterScreen> {
  final SpeechIOService _speech = SpeechIOService();
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _textFocus = FocusNode();
  String _interpretedText = '';
  bool _ready = false;
  bool _readingPreset = false;
  Map<String, dynamic>? _assetManifest;
  List<Map<String, dynamic>> _terms = [];
  Map<String, Map<String, dynamic>> _byKey = {};
  Map<String, Map<String, dynamic>> _byEs = {};
  Map<String, Map<String, dynamic>> _byEn = {};
  bool _lexiconReady = false;
  bool _manifestReady = false;
  String? _captionText;
  String? _imagePath;
  VideoPlayerController? _vp;
  Future<void>? _vpInit;
  String? _emoji;
  Timer? _lookupTimer;

  List<Map<String, dynamic>> _templates = [];
  Map<String, dynamic> _slotTypes = {}; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _speech.init(sttLocale: 'es-MX', ttsLocale: 'es-MX');
      if (!mounted) return;
      setState(() => _ready = _speech.sttReady);
      _textCtrl.text = _interpretedText;
      await _loadLexicon();
      await _loadAssetManifest();
    });
  }

  @override
  void dispose() {
    _lookupTimer?.cancel();
    _textCtrl.dispose();
    _textFocus.dispose();
    _disposeVideo();
    _speech.dispose();
    super.dispose();
  }

  Future<void> _startStt() async {
    if (!_ready || _speech.isListening) return;
    await _speech.startListening(
      localeId: 'es-MX',
      onResult: (text, isFinal) async {
        final limit = InterpreterScreen._charLimit;
        final clipped = text.length > limit ? text.substring(0, limit) : text;
        _textCtrl.value = TextEditingValue(
          text: clipped,
          selection: TextSelection.collapsed(offset: clipped.length),
        );
        setState(() => _interpretedText = clipped);
        _lookupDebounced();
        final speakOn = Provider.of<SpeechProvider>(context, listen: false).enabled;
        if (isFinal && speakOn && _interpretedText.isNotEmpty) {
          await _speech.speak(_interpretedText);
        }
      },
    );
  }

  Future<void> _stopStt() => _speech.stopListening();

  Future<void> _speakPreset() async {
    if (_readingPreset) return;
    setState(() => _readingPreset = true);
    final loc = AppLocalizations.of(context)!;
    await _speech.speak(loc.interpreter_screen_title);
    if (mounted) setState(() => _readingPreset = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final speakOn = Provider.of<SpeechProvider>(context).enabled;
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: CustomAppBar(title: loc.interpreter_screen_title),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;
            if (isPortrait) {
              return _keyboardAwareBody(loc, speakOn);
            }
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: AspectRatio(aspectRatio: 3 / 4, child: _buildCameraPreview(context, loc))),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildContent(context, loc, speakOn, excludeCamera: true))),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Keyboard-aware body (portrait):
  /// - Adapts `textBoxHeight` depending on whether the keyboard is open.
  /// - **Ahora el preview SIEMPRE se ve**, aunque el teclado esté abierto.
  Widget _keyboardAwareBody( AppLocalizations loc, bool speakOn) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final media = MediaQuery.of(context);
        final bool isKeyboardOpen = media.viewInsets.bottom > 0.0;

        // Translate-like box height:
        // - With keyboard: ~50% of available height
        // - Without keyboard: ~30% of available height
        final double textBoxHeight = isKeyboardOpen
            ? (constraints.maxHeight * 0.5)
            : (constraints.maxHeight * 0.30);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  loc.let_your_sign_be_heard,
                  style: AppTextStyles.textTitle.copyWith(
                        color: AppColors.text(context),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),

                // Animated container for the text box + action bar)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: textBoxHeight.clamp(
                    200.0,
                    constraints.maxHeight * 0.75,
                  ),
                  child: _googleLikeBox(loc, speakOn),
                ),

                const SizedBox(height: 16),

                // Mostrar SIEMPRE el preview (antes se ocultaba con teclado)
                Expanded(child: _buildCameraPreview(context, loc)),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Reusable content in landscape (right column).
  List<Widget> _buildContent(
    BuildContext context,
    AppLocalizations loc,
    bool speakOn, {
    bool excludeCamera = false,
  }) {
    return [
      if (!excludeCamera) ...[
        Text(
          loc.let_your_sign_be_heard,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.text(context),
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),

        // Fixed height in landscape
        SizedBox(
          height: 220,
          child: _googleLikeBox(loc, speakOn),
        ),

        const SizedBox(height: 16),

        // Preview
        AspectRatio(aspectRatio: 1, child: _buildCameraPreview(context, loc)),

        const SizedBox(height: 16),
      ],
    ];
  }

  /// style box:
  /// - Editable text area with placeholder.
  /// - “X” button to clear content.
  /// - Bottom bar: Mic/Stop with glow, TTS, counter y botón "Mostrar".
  Widget _googleLikeBox(
    AppLocalizations loc, bool speakOn
  ) {
    final theme = Theme.of(context);
    final bg = AppColors.surface(context);
    final textColor = AppColors.text(context);
    final border = AppColors.primary(context).withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.text(context).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // “X” button: clear content and stop STT/TTS
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.close, color: textColor),
              tooltip: loc.clear,
              onPressed: _interpretedText.isEmpty
                  ? null
                  : () {
                      _textFocus.unfocus();
                      _textCtrl.clear();
                      setState(() {
                        _interpretedText = '';
                        _emoji = null; // clear current emoji
                      });
                      _speech.stopSpeak();
                      _speech.cancelListening();
                      _clearMedia();
                    },
            ),
          ),

          // Main content (text + action bar)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Editable text area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 48, 8),
                  child: TextField(
                    controller: _textCtrl,
                    focusNode: _textFocus,
                    enabled: !_speech.isListening, // prevent editing while dictating
                    maxLines: null,
                    minLines: 3,
                    keyboardType: TextInputType.multiline,
                    textAlign: TextAlign.left,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: loc.translation,
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: textColor.withOpacity(0.55),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    onChanged: (value) {
                      // Enforce manual character limit
                      final limit = InterpreterScreen._charLimit;
                      if (value.length > limit) {
                        final trimmed = value.substring(0, limit);
                        _textCtrl.value = TextEditingValue(
                          text: trimmed,
                          selection: TextSelection.collapsed(
                            offset: trimmed.length,
                          ),
                        );
                      }
                      setState(() => _interpretedText = _textCtrl.text);
                      _lookupDebounced(); // ← lookup JSON + media
                    },
                    onSubmitted: (_) {
                      // Enter: cerrar teclado y forzar resolución
                      FocusScope.of(context).unfocus();
                      _resolveAndShow(_interpretedText);
                    },
                  ),
                ),
              ),

              //emoji on of the text
              if ((_emoji ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _emoji!,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),

              // Bottom bar: Mic/Stop (with glow), TTS, Mostrar, counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: border)),
                ),
                child: Row(
                  children: [
                    // Mic <-> Stop con glow
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder:
                          (child, anim) => ScaleTransition(scale: anim, child: child),
                      child: _speech.isListening
                          ? Container(
                              key: const ValueKey('stop'),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                    color: AppColors.primary(context)
                                        .withOpacity(0.35),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: AppColors.primary(context),
                                shape: const CircleBorder(),
                                child: IconButton(
                                  tooltip: 'Detener grabación',
                                  icon: Icon(Icons.stop_rounded,
                                      color: AppColors.onPrimary(context)),
                                  onPressed: () async {
                                    await _stopStt();
                                    if (mounted) setState(() {}); // refresh icon
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
                                icon: Icon(Icons.mic, color: textColor),
                                onPressed: !_ready
                                    ? null
                                    : () async {
                                        _textFocus.unfocus(); // close keyboard before dictation
                                        await _startStt();
                                        if (mounted) setState(() {}); // refresh icon
                                      },
                              ),
                            ),
                    ),

                    // TTS
                    IconButton(
                      tooltip: loc.speakText,
                      icon: Icon(Icons.volume_up, color: textColor),
                      onPressed: _interpretedText.isEmpty
                          ? null
                          : () async {
                              final speakOn =
                                  Provider.of<SpeechProvider>(context, listen: false)
                                      .enabled;
                              if (speakOn) await _speech.speak(_textCtrl.text);
                            },
                    ),

                    // Mostrar: cierra teclado y resuelve ya
                    IconButton(
                      tooltip: 'Mostrar',
                      icon: Icon(Icons.visibility, color: textColor),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _resolveAndShow(_interpretedText);
                      },
                    ),

                    const Spacer(),

                    // Character counter (current / limit)
                    Text(
                      '${_textCtrl.text.length} / ${InterpreterScreen._charLimit}',
                      style: TextStyle(
                        color: AppColors.text(context).withOpacity(0.55),
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

  /// Preview: shows image or video with a bottom-centered caption.
  Widget _buildCameraPreview(BuildContext context, AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // IMAGE (alphabet or term image) all box
          if (_imagePath != null)
            Positioned.fill(
              child: Image.asset(_imagePath!, fit: BoxFit.cover),
            ),

          // VIDEO all box
          if (_vp != null && _vpInit != null)
            FutureBuilder(
              future: _vpInit,
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.cover,           // <- clave para cubrir
                    clipBehavior: Clip.hardEdge, // <- asegura el recorte
                    child: SizedBox(
                      // Usa el tamaño nativo del video para que FittedBox escale bien
                      width: _vp!.value.size.width,
                      height: _vp!.value.size.height,
                      child: VideoPlayer(_vp!),
                    ),
                  ),
                );
              },
            ),

          // CAPTION (bottom-centered stripe)
          if ((_captionText ?? '').isNotEmpty)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _captionText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.onPrimary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ----------------- Lexicon helpers -----------------

  Future<void> _loadLexicon() async {
    final raw = await rootBundle.loadString('assets/lexicon/interpreter_function.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    _terms = (data['terms'] as List).cast<Map<String, dynamic>>();
    _byKey = {for (final t in _terms) (t['key'] as String): t};
    _byEs  = {for (final t in _terms) _normalize(t['es'] as String): t};
    _byEn  = {for (final t in _terms) _normalize((t['en'] ?? '') as String): t};

    // NEW: cargar templates y slot_types
    _templates  = (data['templates'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    _slotTypes  = (data['slot_types'] as Map<String, dynamic>? ) ?? {};

    _lexiconReady = true;
    if (mounted) setState(() {});
  }

  Future<void> _loadAssetManifest() async {
    final raw = await rootBundle.loadString('AssetManifest.json');
    _assetManifest = json.decode(raw) as Map<String, dynamic>;
    _manifestReady = true;
    if (mounted) setState(() {});
  }

  String _normalize(String input) {
    final lower = input.trim().toLowerCase();
    const map = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ä': 'a',
      'ë': 'e',
      'ï': 'i',
      'ö': 'o',
      'ü': 'u'
    };
    final sb = StringBuffer();
    for (final r in lower.runes) {
      final c = String.fromCharCode(r);
      if (c == 'ñ') {
        sb.write('ñ');
        continue;
      }
      if (map.containsKey(c)) {
        sb.write(map[c]);
        continue;
      }
      if (RegExp(r'[a-z0-9\s]').hasMatch(c)) {
        sb.write(c);
      } else if (c == '-') {
        sb.write(' ');
      }
    }
    return sb.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _isSingleLetter(String s) {
    final t = _normalize(s);
    return t.length == 1 && RegExp(r'^[a-zñ]$').hasMatch(t);
  }

  String _alphabetPath(String s) =>
      'assets/lexicon/images/${s.trim().toUpperCase()}.png';

  // Relajado: if the manifest is not loaded, assume the asset exists
  bool _assetExists(String path) {
    final m = _assetManifest;
    if (m == null || m.isEmpty) return true;
    return m.containsKey(path);
  }

  void _lookupDebounced() {
    _lookupTimer?.cancel();
    _lookupTimer = Timer(const Duration(milliseconds: 180), () {
      if (!_lexiconReady || !_manifestReady) {
        // Reintento corto si aún no cargan
        _lookupTimer = Timer(const Duration(milliseconds: 180), () {
          if (_lexiconReady && _manifestReady) {
            _resolveAndShow(_interpretedText);
          }
        });
        return;
      }
      _resolveAndShow(_interpretedText);
    });
  }

  // close keyboard if open the _media is shown
  void _autoHideKeyboardIfOpen() {
    if (!mounted) return;
    if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
      FocusScope.of(context).unfocus();
    }
  }

  // *** NUEVO: helper para mapear ES/EN a la key canónica (ES) ***
  String? _canonicalBodyPartKey(String tokenNorm) {
    final list = (_slotTypes['body_part'] as List?)?.cast<Map<String, dynamic>>();
    if (list == null) return null;

    for (final item in list) {
      final keyEs = _normalize(item['key'] as String);
      final keyEn = _normalize((item['en'] ?? '') as String);
      if (tokenNorm == keyEs || (keyEn.isNotEmpty && tokenNorm == keyEn)) {
        return item['key'] as String; // devolvemos SIEMPRE la key ES
      }
    }
    return null;
  }

  // Get the emoji to a part of the body from slot_types
  String? _bodyPartEmoji(String parteAny) {
    final list = (_slotTypes['body_part'] as List?)?.cast<Map<String, dynamic>>();
    if (list == null) return null;

    final token = _normalize(parteAny);
    for (final item in list) {
      final keyEs = _normalize(item['key'] as String);
      final keyEn = _normalize((item['en'] ?? '') as String);
      if (token == keyEs || (keyEn.isNotEmpty && token == keyEn)) {
        return item['emoji'] as String?;
      }
    }
    return null;
  }

  // *** NUEVO: helper central para mostrar media de un term por key, con fallback de patrón ***
  void _showTermByKeyOrPattern(String termKey, {String? patternBaseKey}) {
    final term = _byKey[termKey];
    if (term != null) {
      final media = term['media'] as Map<String, dynamic>?;
      final type  = media?['type'] as String?;
      final path  = media?['path'] as String?;

      if (type == 'image' && path != null && _assetExists(path)) {
        _imagePath = path;
        _autoHideKeyboardIfOpen();
        return;
      }
      if (type == 'video' && path != null && _assetExists(path)) {
        _vp = VideoPlayerController.asset(path);
        _vpInit = _vp!.initialize().then((_) {
          _vp!..setLooping(true)..play();
          _autoHideKeyboardIfOpen();
          if (mounted) setState(() {});
        });
        return;
      }
    }

    // Fallback: usa patrón convencional (si no hay term o path)
    final key = patternBaseKey ?? termKey;
    final v = 'assets/lexicon/videos/$key.mp4';
    if (_assetExists(v)) {
      _vp = VideoPlayerController.asset(v);
      _vpInit = _vp!.initialize().then((_) {
        _vp!..setLooping(true)..play();
        _autoHideKeyboardIfOpen();
        if (mounted) setState(() {});
      });
    }
  }

  // resolving "me duele {parte}" template
  bool _tryDolorEnParte(String qNorm) {
    final bodyParts = (_slotTypes['body_part'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (bodyParts.isEmpty) return false;

    final opciones = bodyParts.map((m) => RegExp.escape(m['key'] as String)).join('|');
    final re = RegExp(r'^me duele (?:la |el )?(' + opciones + r')$');

    final m = re.firstMatch(qNorm);
    if (m == null) return false;

    final parte = m.group(1)!;                 // ej. "cabeza"
    final parteEmoji = _bodyPartEmoji(parte);

    // Compón the emoji template
    _emoji = parteEmoji == null ? '🤕' : '🤕 $parteEmoji';

    // Caption (opcional): glosa simple
    _captionText = 'DOLOR ' + parte.toUpperCase();

    // NUEVO: intenta usar un term explícito "dolor_{parte}" y si no, fallback al patrón
    _showTermByKeyOrPattern('dolor_${parte}', patternBaseKey: 'dolor_${parte}');
    return true;
  }

  // resolving English pain templates: "my {part} hurts", "it hurts my {part}", "headache"
  bool _tryPainInPartEn(String qNorm) {
    // body_part keys se asumen en inglés (e.g., head, arm, leg)
    final bodyParts = (_slotTypes['body_part'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (bodyParts.isEmpty) return false;

    // Opciones en INGLÉS (fallback a key ES si falta "en")
    final opcionesEn = bodyParts.map((m) {
      final enVal = (m['en'] ?? m['key']) as String;
      return RegExp.escape(_normalize(enVal));
    }).join('|');

    // 1) "my head hurts" / "the head hurts" / "head hurts"
    final reA = RegExp(r'^(?:my |the )?(' + opcionesEn + r') hurts$');

    // 2) "it hurts my head" / "hurts my head"
    final reB = RegExp(r'^(?:it )?hurts (?:my |the )?(' + opcionesEn + r')$');

    // 3) "headache" / "i have a headache" -> map to head
    final isHeadache = qNorm == 'headache' || RegExp(r'^i have (?:a )?headache$').hasMatch(qNorm);

    String? parteToken;
    if (isHeadache) {
      parteToken = 'head';
    } else {
      Match? m = reA.firstMatch(qNorm) ?? reB.firstMatch(qNorm);
      if (m != null) {
        parteToken = m.group(1);
      }
    }

    if (parteToken == null) return false;

    final canonKey = _canonicalBodyPartKey(_normalize(parteToken)) ?? parteToken;
    final parteEmoji = _bodyPartEmoji(parteToken);

    _emoji = parteEmoji == null ? '🤕' : '🤕 $parteEmoji';
    _captionText = 'DOLOR ' + canonKey.toUpperCase();

    // NUEVO: term "dolor_{canonKey}" o fallback al patrón
    _showTermByKeyOrPattern('dolor_${canonKey}', patternBaseKey: 'dolor_${canonKey}');
    return true;
  }

  void _resolveAndShow(String query) {
    if (!_lexiconReady) return; // guard extra

    _disposeVideo();
    _imagePath = null;
    _captionText = null;
    _emoji = null;

    final q = _normalize(query);
    if (q.isEmpty) {
      setState(() {});
      return;
    }

    // Letter → alphabet image
    if (_isSingleLetter(q)) {
      final p = _alphabetPath(q);
      if (_assetExists(p)) {
        _imagePath = p;
        _captionText = q.toUpperCase();
        _autoHideKeyboardIfOpen();
      }
      setState(() {});
      return;
    }

    //  Try "me duele {parte}" template
    if (_tryDolorEnParte(q)) {
      setState(() {});
      return;
    }
    // Try English pain templates: "my {part} hurts", "it hurts my {part}", "headache"
    if (_tryPainInPartEn(q)) {
      setState(() {});
      return;
    }

    // Exact match (by es or key)
    Map<String, dynamic>? term = _byEs[q] ?? _byEn[q] ?? _byKey[q];

    // Fallback: simple prefix/contains
    if (term == null) {
      Map<String, dynamic>? best;
      int bestScore = -1;
      for (final t in _terms) {
        final esn = _normalize(t['es'] as String);
        final enn = _normalize((t['en'] ?? '') as String); // NEW
        int s = -1;

        bool eq  = (esn == q) || (enn == q);
        bool pre = esn.startsWith(q) || (enn.isNotEmpty && enn.startsWith(q));
        bool con = esn.contains(q)   || (enn.isNotEmpty && enn.contains(q));

        if (eq) {
          s = 3;
        } else if (pre) {
          s = 2;
        } else if (con) {
          s = 1;
        }

        if (s > bestScore) {
          bestScore = s;
          best = t;
        }
      }
      if (bestScore >= 1) term = best;
    }

    if (term != null) {
      // caption: caption.text or 'es'
      final caption =
          (term['caption']?['text'] as String?) ?? (term['es'] as String);
      _captionText = caption;
      _emoji = term['emoji'] as String?;

      // media
      final media = term['media'] as Map<String, dynamic>?;
      final type = media?['type'] as String?;
      final path = media?['path'] as String?;

      if (type == 'image' && path != null && _assetExists(path)) {
        _imagePath = path;
        _autoHideKeyboardIfOpen();
      } else if (type == 'video' && path != null && _assetExists(path)) {
        _vp = VideoPlayerController.asset(path);
        _vpInit = _vp!.initialize().then((_) {
          _vp!..setLooping(true)..play();
          _autoHideKeyboardIfOpen();
          if (mounted) setState(() {});
        });
      } else {
        // Fallback: try conventional video path by key
        final key = term['key'] as String;
        final v = 'assets/lexicon/videos/$key.mp4';
        if (_assetExists(v)) {
          _vp = VideoPlayerController.asset(v);
          _vpInit = _vp!.initialize().then((_) {
            _vp!..setLooping(true)..play();
            _autoHideKeyboardIfOpen();
            if (mounted) setState(() {});
          });
        }
      }
    }

    setState(() {});
  }

  void _disposeVideo() {
    _vp?.pause();
    _vp?.dispose();
    _vp = null;
    _vpInit = null;
  }

  void _clearMedia() {
    _disposeVideo();
    _imagePath = null;
    _captionText = null;
    _emoji = null;
    setState(() {});
  }
}
