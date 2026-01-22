import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:supertonic_flutter/supertonic_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SupertonicTTS _tts = SupertonicTTS();
  final TTSAudioPlayer _player = TTSAudioPlayer();
  final TextEditingController _textController = TextEditingController();

  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isSpeaking = false;
  String _selectedVoice = 'M1';
  String _selectedLang = 'en';
  double _speechSpeed = 1.05;
  int _denoisingSteps = 5;
  String? _errorMessage;

  final List<String> _availableVoices = [
    'M1',
    'M2',
    'M3',
    'M4',
    'M5',
    'F1',
    'F2',
    'F3',
    'F4',
    'F5',
  ];

  final List<TTSLanguage> _availableLanguages = TTSLanguage.all;

  @override
  void initState() {
    super.initState();
    _textController.text = TTSTestStrings.shortForLanguage('en');
    // Delay initialization until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTTS();
    });
    _setupAudioPlayerListeners();
  }

  void _setupAudioPlayerListeners() {
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        // Update speaking state based on both playing and processing state
        _isSpeaking =
            state.playing && state.processingState != ProcessingState.completed;
      });
    });
  }

  Future<void> _initializeTTS() async {
    if (_isInitialized) return;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      await _tts.initialize();
      setState(() {
        _isInitialized = true;
        _isInitializing = false;
        _errorMessage = null;
      });
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Failed to initialize TTS: $e';
      });
    }
  }

  Future<void> _speak() async {
    debugPrint('Speak button clicked');
    debugPrint(
      'Initialized: $_isInitialized, Text empty: ${_textController.text.isEmpty}',
    );

    if (!_isInitialized || _textController.text.isEmpty) {
      debugPrint('Speak returned early: not initialized or empty text');
      return;
    }

    debugPrint('Starting synthesis...');
    setState(() {
      _isSpeaking = true;
      _errorMessage = null;
    });

    try {
      final config = TTSConfig(
        denoisingSteps: _denoisingSteps,
        speechSpeed: _speechSpeed,
      );

      debugPrint('Calling tts.synthesize...');
      final result = await _tts.synthesize(
        _textController.text,
        language: _selectedLang,
        voiceStyle: _selectedVoice,
        config: config,
      );

      debugPrint(
        'Synthesis complete, audio length: ${result.audioData.length}',
      );
      debugPrint('Playing audio...');
      await _player.play(result);
      debugPrint('Audio playback started');
    } catch (e, stackTrace) {
      debugPrint('Error during synthesis: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() {
        _errorMessage = 'TTS error: $e';
      });
    } finally {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  Future<void> _stop() async {
    await _player.stop();
    setState(() {
      _isSpeaking = false;
    });
  }

  void _setTestString(String langCode) {
    setState(() {
      _selectedLang = langCode;
      _textController.text = TTSTestStrings.shortForLanguage(langCode);
    });
  }

  String _getFlag(String langCode) {
    const flags = {
      'en': '🇺🇸',
      'es': '🇪🇸',
      'fr': '🇫🇷',
      'de': '🇩🇪',
      'it': '🇮🇹',
      'pt': '🇵🇹',
      'ko': '🇰🇷',
      'ja': '🇯🇵',
      'zh': '🇨🇳',
    };
    return flags[langCode] ?? '🌐';
  }

  @override
  void dispose() {
    _textController.dispose();
    _player.dispose();
    _tts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Supertonic TTS Demo'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isSpeaking ? _stop : _speak,
          child: Icon(_isSpeaking ? Icons.stop : Icons.play_arrow, size: 32),
        ),
        body: SafeArea(
          child: _isInitializing
              ? const Center(child: CircularProgressIndicator())
              : !_isInitialized
              ? Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SelectableText(
                          _errorMessage ?? 'Failed to initialize TTS',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializeTTS,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Language selection
                        const Text(
                          'Language',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableLanguages.map((lang) {
                            final isSelected = lang.code == _selectedLang;
                            final flag = _getFlag(lang.code);
                            return ChoiceChip(
                              label: Text('$flag ${lang.nativeName}'),
                              selected: isSelected,
                              onSelected: (selected) {
                                _setTestString(lang.code);
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Voice selection
                        const Text(
                          'Voice Style',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableVoices.map((voice) {
                            final isSelected = voice == _selectedVoice;
                            return ChoiceChip(
                              label: Text(voice),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedVoice = voice;
                                });
                              },
                            );
                          }).toList(),
                        ),

                        // Voice description card
                        const SizedBox(height: 12),
                        Card(
                          color: Colors.blue.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      _selectedVoice.startsWith('M')
                                          ? Icons.male
                                          : Icons.female,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$_selectedVoice - ${TTSVoiceStyle.fromCode(_selectedVoice).gender} Voice',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  TTSVoiceStyle.fromCode(
                                    _selectedVoice,
                                  ).description,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Best for:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  TTSVoiceStyle.fromCode(
                                    _selectedVoice,
                                  ).useCases,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Speech speed
                        Text(
                          'Speech Speed: ${_speechSpeed.toStringAsFixed(2)}x',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: _speechSpeed,
                          min: 0.5,
                          max: 2.0,
                          divisions: 15,
                          label: _speechSpeed.toStringAsFixed(2),
                          onChanged: (value) {
                            setState(() {
                              _speechSpeed = value;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Denoising steps
                        Text(
                          'Quality (Denoising Steps): $_denoisingSteps',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Slider(
                          value: _denoisingSteps.toDouble(),
                          min: 1,
                          max: 20,
                          label: _denoisingSteps.toString(),
                          onChanged: (value) {
                            setState(() {
                              _denoisingSteps = value.toInt();
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // Text input
                        const Text(
                          'Text to Speak',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _textController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: 'Enter text here...',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Reset to test string',
                              onPressed: () {
                                _textController.text =
                                    TTSTestStrings.shortForLanguage(
                                      _selectedLang,
                                    );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error display (if any)
                        if (_errorMessage != null)
                          Card(
                            color: Colors.red.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        _errorMessage = null;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (_errorMessage != null) const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
