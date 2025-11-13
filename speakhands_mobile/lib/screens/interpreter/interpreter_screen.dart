import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/screens/interpreter/widgets/carrusel_modal.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/theme/text_styles.dart';
import 'package:video_player/video_player.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/service/speech_io_service.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/screens/interpreter/functions/buildcamerapreview.dart';
import 'package:speakhands_mobile/widgets/draggable_fab.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

/// ---------------------------------------------------------------------------
/// Screen: INTERPRETER (voice ↔ text)
/// ---------------------------------------------------------------------------
/// Purpose:
/// - Voice input (Speech-to-Text) via `speech_to_text`.
/// - Text-to-Speech playback via `flutter_tts`.
/// - Editable text box featuring:
///   • placeholder, character counter, clear button, mic/stop toggle with glow.
///   • keyboard-aware behavior: the box grows when the keyboard is open.
/// - Text → (video | alphabet image) using lexicon JSON.
///   Shows bottom-centered caption over media (e.g., "hola").
/// ---------------------------------------------------------------------------

class InterpreterScreen extends StatefulWidget {
  const InterpreterScreen({super.key});

  @override
  State<InterpreterScreen> createState() => _InterpreterScreenState();

  /// Character limit shown/enforced in the text box
  static const int _charLimit = 1000;
}

class _InterpreterScreenState extends State<InterpreterScreen> {
  // Unified service for STT + TTS (init, listen, speak, etc.)
  final SpeechIOService _speech = SpeechIOService();

  // Text controllers for the editable box
  final TextEditingController _textCtrl = TextEditingController();
  final FocusNode _textFocus = FocusNode();

  /// The base URL for the remote media server (Ngrok/MinIO).
  final String baseUrl = 'https://orville-unclosable-victoria.ngrok-free.dev';

  // “Interpreted” text (filled either by STT or your LSM → text pipeline)
  String _interpretedText = '';
  bool _ready = false;
  bool _readingPreset = false;

  // === LEXICON / MEDIA STATE ===
  Map<String, dynamic>? _assetManifest;

  // Lexicon terms & indices
  List<Map<String, dynamic>> _terms = [];
  Map<String, Map<String, dynamic>> _byKey = {};
  Map<String, Map<String, dynamic>> _byEs  = {};
  Map<String, Map<String, dynamic>> _byEn = {};
  List<Map<String, dynamic>> _templates = [];
  Map<String, dynamic> _slotTypes = {};
  bool _lexiconReady = false;
  bool _manifestReady = false;

  // Current media
  String? _captionText;
  String? _imagePath;
  File? _imageFile;
  String? _imageUrl;
  VideoPlayerController? _vp;
  Future<void>? _vpInit;

  // Current emoji (not used yet)
  String? _emoji;

  // Debounce for lookups
  Timer? _lookupTimer;

  /// Displays an error message in the [CameraPreviewWidget] if media
  /// fails to load from both online (streaming) and offline (local) sources.
  String? _mediaError;

  @override
  void initState() {
    super.initState();

    // Use addPostFrameCallback to ensure a mounted context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Initialize STT + TTS
      await _speech.init(sttLocale: 'es-MX', ttsLocale: 'es-MX');
      if (!mounted) return;
      setState(() => _ready = _speech.sttReady);

      // Sync controller with initial state
      _textCtrl.text = _interpretedText;

      // If voice output is enabled, play a short welcome message
      final speakOn =
          Provider.of<SpeechProvider>(context, listen: false).enabled;
      if (speakOn) {
        final loc = AppLocalizations.of(context)!;
        final lc = Localizations.localeOf(context).languageCode;
        await _speech.speak(loc.learn_info, languageCode: lc);
      }

      // Load lexicon + manifest (for media lookup)
      await _loadLexicon();
      await _loadAssetManifest();
    });
  }

  @override
  void dispose() {
    // Release text controllers
    _lookupTimer?.cancel();
    _textCtrl.dispose();
    _textFocus.dispose();

    // Release video & STT/TTS resources
    _disposeVideo();
    _speech.dispose();
    super.dispose();
  }

  // ----------------- STT control -----------------

  /// Starts voice recognition.
  /// - `partialResults: true`: show partial results in real time.
  /// - On final result, if voice output is enabled, read it aloud.
  Future<void> _startStt() async {
    if (!_ready || _speech.isListening) return;
    await _speech.startListening(
      localeId: 'es-MX',
      onResult: (text, isFinal) async {
        // Respect character limit to avoid UI overflow
        final limit = InterpreterScreen._charLimit;
        final clipped = text.length > limit ? text.substring(0, limit) : text;

        // Update controller and state with dictated text
        _textCtrl.value = TextEditingValue(
          text: clipped,
          selection: TextSelection.collapsed(offset: clipped.length),
        );
        setState(() => _interpretedText = clipped);

        // Trigger media lookup
        _lookupDebounced();

        // On final result, speak if enabled and there is text
        final speakOn =
            Provider.of<SpeechProvider>(context, listen: false).enabled;
        if (isFinal && speakOn && _interpretedText.isNotEmpty) {
          await _speech.speak(_interpretedText);
        }
      },
    );
  }

  void _CarouselModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CarouselModal(),
    );
  }

  Future<void> _stopStt() => _speech.stopListening();

  /// Plays a preset text (handy for quick testing).
  Future<void> _speakPreset() async {
    if (_readingPreset) return;
    setState(() => _readingPreset = true);
    final loc = AppLocalizations.of(context)!;
    await _speech.speak(loc.interpreter_screen_title);
    if (mounted) setState(() => _readingPreset = false);
  }

  // ----------------- Build -----------------

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final speakOn = Provider.of<SpeechProvider>(context).enabled;
    
    final authHeader = {'ngrok-skip-browser-warning': 'true'};

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: CustomAppBar(title: loc.interpreter_screen_title),

      // Let the body resize when the keyboard shows
      resizeToAvoidBottomInset: true,

      // Dismiss the keyboard when tapping outside the TextField
      body: LayoutBuilder( 
        builder: (context, constraints) {
          final buttonSize = 50.0;
          final screenPadding = 16.0;
          final initialRightPosition = constraints.maxWidth - buttonSize - screenPadding;

          return Stack( 
            children: [
              // --- principal content  ---
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    final isPortrait = orientation == Orientation.portrait;

                    if (isPortrait) {
                      return _keyboardAwareBody(loc, speakOn, authHeader);
                    }

                    // Landscape layout
                    return SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(screenPadding),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 3 / 4,
                                child: CameraPreviewWidget(
                                  imagePath: _imagePath,
                                  imageFile: _imageFile,
                                  imageUrl: _imageUrl,
                                  authHeaders: authHeader,
                                  vp: _vp,
                                  vpInit: _vpInit,
                                  captionText: _captionText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildContent(
                                  context,
                                  loc,
                                  speakOn,
                                  authHeader,
                                  excludeCamera: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              DraggableFAB(
                storageKey: 'interpreter_screen_fab_position',
                initialTop: 570.0,
                initialLeft: initialRightPosition,
                constraints: constraints, 
                onPressed: _CarouselModal, 
              ),
            ],
          );
        }
      ),
    );
  }

  /// Keyboard-aware body (portrait):
  Widget _keyboardAwareBody( AppLocalizations loc, bool speakOn, Map<String, String> authHeader) {
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

                // Animated container...
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: textBoxHeight.clamp(
                    200.0,
                    constraints.maxHeight * 0.75,
                  ),
                  child: _googleLikeBox(loc, speakOn),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: CameraPreviewWidget(
                    imagePath: _imagePath,
                    imageFile: _imageFile,
                    imageUrl: _imageUrl,
                    authHeaders: authHeader,
                    vp: _vp,
                    vpInit: _vpInit,
                    captionText: _captionText,
                    mediaError: _mediaError,
                  )
                ),
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
    bool speakOn,
    Map<String, String> authHeader,
    {
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
        AspectRatio(aspectRatio: 1, child: CameraPreviewWidget(
                          imagePath: _imagePath,
                          imageFile: _imageFile,
                          imageUrl: _imageUrl,
                          authHeaders: authHeader,
                          vp: _vp,
                          vpInit: _vpInit,
                          captionText: _captionText,
                          mediaError: _mediaError,
                        ),),

        const SizedBox(height: 16),
      ],
    ];
  }

  /// style box:
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
                    textInputAction: TextInputAction.done,
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
                      onPressed: _interpretedText.trim().isEmpty
                          ? null
                          : () async {
                              await _speech.stopSpeak();
                              await _speech.speak(_textCtrl.text);
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
    const map = {'á': 'a',  'é': 'e',  'í': 'i',  'ó': 'o',  'ú': 'u',  'ä': 'a',  'ë': 'e',  'ï': 'i',  'ö': 'o',  'ü': 'u'
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
  
  /// Removes the 'assets/' prefix from lexicon paths.
  
  /// The JSON file may contain full asset paths (e.g., 'assets/lexicon/videos/hola.mp4').
  /// This function strips the prefix to get the bare resource name (e.g., 'hola.mp4')
  /// needed for Docker and local file saving.
  String _cleanPath(String path) {
    const String prefixVideo = 'assets/lexicon/videos/';
    const String prefixImage = 'assets/lexicon/images/';
    
    if (path.startsWith(prefixVideo)) {
      return path.substring(prefixVideo.length); 
    }
    if (path.startsWith(prefixImage)) {
      return path.substring(prefixImage.length); 
    }
    return path; 
  }

  /// Gets the local [File] reference for a downloaded (offline) resource.
  ///
  /// This creates the 'videos' or 'imagenes' subdirectory if it doesn't exist.
  Future<File> _getLocalFile(String resourceName, String type) async {
    final directory = await getApplicationDocumentsDirectory();
    final folder = (type == 'video') ? 'videos' : 'imagenes';
    
    final Directory subDir = Directory('${directory.path}/$folder');
    if (!await subDir.exists()) {
      await subDir.create(recursive: true);
    }
    
    return File('${subDir.path}/$resourceName');
  }

  /// Attempts to initialize and play a video directly from the remote [url].

  /// Creates a new [VideoPlayerController] for the network [url].
  /// Throws an exception if the video fails to initialize (e.g., 404
  /// or network error), which is then caught by [_displayMedia].
  Future<void> _streamVideoFromDocker(String url) async {
    _disposeVideo();
    final headers = {'ngrok-skip-browser-warning': 'true'};

    _vp = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: headers,
    );

    try {
      _vpInit = _vp!.initialize();
      await _vpInit; 

      setState(() {
        _vp!.setLooping(true);
        _vp!.play();
      });
      _autoHideKeyboardIfOpen();
    } catch (e) {
      print("Error inicializando video desde URL: $e");
      // ¡Relanza el error para que _displayMedia lo atrape!
      throw e;
    }
  }

  /// Sets the [_imageUrl] to stream an image from the remote [url].
  
  /// This does not await the load; the `Image.network` widget handles
  /// the loading, error, and placeholder UI.
  Future<void> _streamImageFromDocker(String url) async {
    _disposeVideo();
    setState(() {
      _imagePath = null;
      _imageFile = null;
      _imageUrl = url;
    });
    _autoHideKeyboardIfOpen();
  }

  /// Main media loading logic with an "Online-First" strategy.
  ///
  /// 1. **Online (Stream):** Tries to stream the media from the [baseUrl].
  /// 2. **Offline (Local):** If streaming fails (throws any exception, like
  ///    no internet or 404), it searches for the media in local storage
  ///    (files downloaded by [DownloadService]).
  /// 3. **Error:** If both fail, it sets [_mediaError] to display a
  ///    "needs download" message.
  Future<void> _displayMedia(String resourceName, String type) async {
    // 1. Limpiar estado
    _disposeVideo();
    setState(() {
      _imagePath = null;
      _imageFile = null;
      _imageUrl = null;
      _mediaError = null; 
    });

    try {
      print("Mostrando desde [Red/Docker]: $resourceName");
      String url = '';
      if (type == 'video') {
        url = '$baseUrl/lexicon/videos/$resourceName';
        await _streamVideoFromDocker(url); 
      } else {
        url = '$baseUrl/lexicon/imagenes/$resourceName';
        await _streamImageFromDocker(url); 
      }
      return; 
    } catch (e) {
      print("Fallo online ($e), buscando en [Local Storage]: $resourceName");
      
      final File localFile = await _getLocalFile(resourceName, type);

      if (await localFile.exists()) {
        print("Encontrado en [Local Storage]: ${localFile.path}");
        if (type == 'video') {
          _vp = VideoPlayerController.file(localFile);
          _vpInit = _vp!.initialize().then((_) {
            _vp!..setLooping(true)..play();
            if (mounted) setState(() {});
          });
        } else {
          setState(() => _imageFile = localFile);
        }
        _autoHideKeyboardIfOpen();
        return; 
      }
    }

    print("No encontrado en ningún lado. Mostrando error.");
    setState(() {
      _mediaError = "Sin conexión. Descarga el modo offline desde Ajustes.";
    });
  }

  bool _assetExists(String path) {
    final m = _assetManifest;
    if (m == null || m.isEmpty) return true;
    if (m.containsKey(path)) {
      return true;
    } else {
      return false;
    }
  }

  bool _isSingleLetter(String s) {
    final t = _normalize(s);
    return t.length == 1 && RegExp(r'^[a-zñ]$').hasMatch(t);
  }

  String _alphabetPath(String s) =>
      'assets/lexicon/images/${s.trim().toUpperCase()}.png';

  void _lookupDebounced() {
    _lookupTimer?.cancel();
    _lookupTimer = Timer(const Duration(milliseconds: 180), () {
      if (!_lexiconReady || !_manifestReady) {
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

  String? _canonicalBodyPartKey(String tokenNorm) {
    final list = (_slotTypes['body_part'] as List?)?.cast<Map<String, dynamic>>();
    if (list == null) return null;

    for (final item in list) {
      final keyEs = _normalize(item['key'] as String);
      final keyEn = _normalize((item['en'] ?? '') as String);
      if (tokenNorm == keyEs || (keyEn.isNotEmpty && tokenNorm == keyEn)) {
        return item['key'] as String;
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

  /// Displays media for a term, handling complex template fallbacks.
  
  /// 1. **Asset:** Checks if the [path] from the JSON exists in local `assets/`.
  /// 2. **Online/Offline:** If not in assets, it cleans the path (e.g., 'hola.mp4')
  ///    and calls [_displayMedia] to handle the Online-First logic.
  void _showTermByKeyOrPattern(String termKey, {String? patternBaseKey}) {
    final term = _byKey[termKey];
    String? path;
    String? type;

    if (term != null) {
      final media = term['media'] as Map<String, dynamic>?;
      type = media?['type'] as String?;
      path = media?['path'] as String?;
    }

    if (path != null && type != null) {
      if (_assetExists(path)) {
        print("Mostrando (helper) desde [Local Asset]: $path");
        if (type == 'video') {
          _vp = VideoPlayerController.asset(path);
          _vpInit = _vp!.initialize().then((_) {
            _vp!..setLooping(true)..play();
            _autoHideKeyboardIfOpen();
            if (mounted) setState(() {});
          });
        } else if (type == 'image') {
          _imagePath = path; 
          _autoHideKeyboardIfOpen();
        }
      } else {
        final resourceName = _cleanPath(path);
        _displayMedia(resourceName, type);
      }
      return;
    }

    final key = patternBaseKey ?? termKey;
    final resourceName = '$key.mp4';
    _displayMedia(resourceName, 'video');
  }

  // resolving "me duele {parte}" template
  bool _tryDolorEnParte(String qNorm) {
    final bodyParts = (_slotTypes['body_part'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (bodyParts.isEmpty) return false;

    final opciones = bodyParts.map((m) => RegExp.escape(m['key'] as String)).join('|');
    final re = RegExp(r'^me duele (?:la |el )?(' + opciones + r')$');

    final m = re.firstMatch(qNorm);
    if (m == null) return false;
    final parte = m.group(1)!;
    final parteEmoji = _bodyPartEmoji(parte);

    // Compón the emoji template
    _emoji = parteEmoji == null ? '🤕' : '🤕 $parteEmoji';

    // Caption (opcional): glosa simple
    _captionText = 'DOLOR ' + parte.toUpperCase();
    _showTermByKeyOrPattern('dolor_${parte}', patternBaseKey: 'dolor_${parte}');
    return true;
  }

  // resolving English pain templates: "my {part} hurts", "it hurts my {part}", "headache"
  bool _tryPainInPartEn(String qNorm) {
    // body_part keys se asumen en inglés (e.g., head, arm, leg)
    final bodyParts = (_slotTypes['body_part'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (bodyParts.isEmpty) return false;
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
    _showTermByKeyOrPattern('dolor_${canonKey}', patternBaseKey: 'dolor_${canonKey}');
    return true;
  }

  // The central lookup function called by the text field.
  ///
  /// It resolves the user's query [String] to a term and then decides
  /// how to display the media.
  /// 1. **Alphabet:** If it's a single letter, shows the local asset.
  /// 2. **Templates:** Tries to match 'dolor' (pain) templates.
  /// 3. **Term:** Finds a matching term.
  ///    - If the term's media is a local asset (`_assetExists` is true),
  ///      it loads from assets.
  ///    - Otherwise, it calls [_displayMedia] to handle the Online/Offline logic.
  void _resolveAndShow(String query) {
    if (!_lexiconReady) return; 

    _disposeVideo();
    _imagePath = null;
    _imageFile = null; 
    _imageUrl = null;  
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
        final enn = _normalize((t['en'] ?? '') as String); 
        int s = -1;

        bool eq  = (esn == q) || (enn == q);
        bool pre = esn.startsWith(q) || (enn.isNotEmpty && enn.startsWith(q));
        bool con = esn.contains(q)   || (enn.isNotEmpty && enn.contains(q));
        if (eq) s = 3;
        else if (pre) s = 2;
        else if (con) s = 1;
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

      if (type != null && path != null) {
        if (_assetExists(path)) {
          print("Mostrando desde [Local Asset]: $path");
          if (type == 'video') {
            _vp = VideoPlayerController.asset(path);
            _vpInit = _vp!.initialize().then((_) {
              _vp!..setLooping(true)..play();
              _autoHideKeyboardIfOpen();
              if (mounted) setState(() {});
            });
          } else if (type == 'image') {
            _imagePath = path;
            _autoHideKeyboardIfOpen();
          }
        } else {
          final resourceName = _cleanPath(path);
          _displayMedia(resourceName, type);
        }
      } else {
        final key = term['key'] as String;
        final resourceName = '$key.mp4';
        _displayMedia(resourceName, 'video');
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
  /// Resets all media state variables to their default (null) values.
  /// This is called when the 'X' button is pressed.
  void _clearMedia() {
    _disposeVideo();
    _imagePath = null;
    _imageFile = null; 
    _imageUrl = null; 
    _captionText = null;
    _emoji = null;
    _mediaError = null;
    setState(() {});
  }
}
