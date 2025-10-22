import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speakhands_mobile/widgets/custom_app_bar.dart';
import 'package:speakhands_mobile/providers/speech_provider.dart';
import 'package:speakhands_mobile/service/speech_io_service.dart';
import 'package:speakhands_mobile/theme/theme.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';
import 'package:speakhands_mobile/providers/theme_provider.dart';

/// ---------------------------------------------------------------------------
/// Screen: INTERPRETER (voice ↔ text)
/// ---------------------------------------------------------------------------
/// Purpose:
/// - Voice input (Speech-to-Text) via `speech_to_text`.
/// - Text-to-Speech playback via `flutter_tts`.
/// - Editable text box featuring:
///   • placeholder, character counter, clear button, mic/stop toggle with glow.
///   • keyboard-aware behavior: the box grows when the keyboard is open.
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

  // “Interpreted” text (filled either by STT or your LSM → text pipeline)
  String _interpretedText = '';

  // State flags
  bool _ready = false; // STT is initialized and ready
  bool _readingPreset = false; // playing a sample text

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
    });
  }

  @override
  void dispose() {
    // Release text controllers
    _textCtrl.dispose();
    _textFocus.dispose();

    // Release STT/TTS resources (mic, TTS queues, etc.)
    _speech.dispose();
    super.dispose();
  }

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

        // On final result, speak if enabled and there is text
        final speakOn =
            Provider.of<SpeechProvider>(context, listen: false).enabled;
        if (isFinal && speakOn && _interpretedText.isNotEmpty) {
          await _speech.speak(_interpretedText);
        }
      },
    );
  }

  /// Stops voice recognition (if active).
  Future<void> _stopStt() => _speech.stopListening();

  /// Plays a preset text (handy for quick testing).
  Future<void> _speakPreset() async {
    if (_readingPreset) return;
    setState(() => _readingPreset = true);
    final loc = AppLocalizations.of(context)!;
    await _speech.speak(
      loc.interpreter_screen_title);
    if (mounted) setState(() => _readingPreset = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final loc = AppLocalizations.of(context)!;
    final speakOn = Provider.of<SpeechProvider>(context).enabled;

    return Scaffold(
      appBar: CustomAppBar(title: loc.interpreter_screen_title),
      
      // Let the body resize when the keyboard shows
      resizeToAvoidBottomInset: true,

      // Dismiss the keyboard when tapping outside the TextField
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: OrientationBuilder(
          builder: (context, orientation) {
            final isPortrait = orientation == Orientation.portrait;

            // Portrait: keyboard-aware body (box grows when the keyboard opens)
            if (isPortrait) {
              return _keyboardAwareBody(themeProvider, loc, speakOn);
            }

            // Landscape: two-column layout (left preview, right controls)
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: _buildCameraPreview(context, loc),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildContent(
                          context,
                          themeProvider,
                          loc,
                          speakOn,
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
    );
  }

  /// Keyboard-aware body (portrait):
  /// - Adapts `textBoxHeight` depending on whether the keyboard is open.
  /// - Hides the preview when the keyboard is visible to prioritize typing.
  Widget _keyboardAwareBody(
    ThemeProvider themeProvider,
    AppLocalizations loc,
    bool speakOn,
  ) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.let_your_sign_be_heard,
                  style: const TextStyle(
                    fontSize: 22,
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
                  child: _googleLikeBox(themeProvider, loc, speakOn),
                ),

                const SizedBox(height: 16),

                // Show preview only when the keyboard is NOT open
                if (!isKeyboardOpen)
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

        // Fixed height in landscape
        SizedBox(
          height: 220,
          child: _googleLikeBox(themeProvider, loc, speakOn),
        ),

        const SizedBox(height: 16),

        // Placeholder preview (e.g., for camera or visual output)
        AspectRatio(aspectRatio: 1, child: _buildCameraPreview(context, loc)),

        const SizedBox(height: 16),
      ],
    ];
  }

  /// style box:
  /// - Editable text area with placeholder.
  /// - “X” button to clear content.
  /// - Bottom bar: Mic/Stop with glow, TTS, and character counter.
  Widget _googleLikeBox(
    ThemeProvider themeProvider,
    AppLocalizations loc,
    bool speakOn,
  ) {
    final theme = Theme.of(context);

    // Text color according to current theme
    final Color baseTextColor =
        theme.textTheme.bodyLarge?.color ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black87);

    // Background according to theme
    final isDark = themeProvider.isDarkMode;
    final bg = isDark ? AppTheme.darkSecondary : AppTheme.lightSecondary;

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
          // “X” button: clear content and stop STT/TTS
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              tooltip: loc.clear,
              onPressed:
                  _interpretedText.isEmpty
                      ? null
                      : () {
                        _textFocus.unfocus();
                        _textCtrl.clear();
                        setState(() => _interpretedText = '');
                        _speech.stopSpeak();
                        _speech.cancelListening();
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
                        color: Colors.black.withOpacity(0.55),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
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
                    },
                  ),
                ),
              ),

              // Bottom bar: Mic/Stop (with glow), TTS, counter
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),

                child: Row(
                  children: [
                    // Mic <-> Stop with animation and glow while listening
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder:
                          (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                      child:
                          _speech.isListening
                              ? Container(
                                key: const ValueKey('stop'),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,

                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 18,
                                      spreadRadius: 2,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.35),
                                    ),
                                  ],
                                ),

                                child: Material(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: const CircleBorder(),
                                  child: IconButton(
                                    tooltip: 'Detener grabación',
                                    icon: const Icon(
                                      Icons.stop_rounded,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      await _stopStt();
                                      if (mounted)
                                        setState(() {}); // refresh icon
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
                                  onPressed:
                                      !_ready
                                          ? null
                                          : () async {
                                            _textFocus.unfocus(); // close keyboard before dictation
                                            await _startStt();
                                            if (mounted) setState(() {},); // refresh icon
                                          },
                                ),
                              ),
                    ),

                    // TTS: read current content aloud
                    IconButton(
                      tooltip: loc.speakText,
                      icon: const Icon(Icons.volume_up),
                      onPressed:
                          _interpretedText.isEmpty
                              ? null
                              : () async {
                                if (speakOn)
                                  await _speech.speak(_textCtrl.text);
                              },
                    ),

                    const Spacer(),

                    // Character counter (current / limit)
                    Text(
                      '${_textCtrl.text.length} / ${InterpreterScreen._charLimit}',
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

  /// Preview placeholder (e.g., camera feed or future visual output).
  /// For now it just shows a gray box; structure is ready.
  Widget _buildCameraPreview(BuildContext context, AppLocalizations loc) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.grey[300])
        )
      ],
    );
  }
}
