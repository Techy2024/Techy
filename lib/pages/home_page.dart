import 'package:bookfx/bookfx.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Techy/api/ollama_llama3.dart';
import 'package:Techy/pages/Diary.dart';
import 'package:Techy/pages/Note.dart';
import 'package:Techy/pages/calendar_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Techy/services/location_service.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'address_settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firebase user
  final user = FirebaseAuth.instance.currentUser!;

  // Character type and animation
  String type = 'ENFJ';
  String _gifPath = 'lib/assets/gif/INTJ/shake_head.gif';
  
  // Controllers and services
  final TextEditingController _controller = TextEditingController();
  final OllamaApiService apiService = OllamaApiService();
  final SpeechToText _speechToText = SpeechToText();
  
  // State variables
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isLoading = false;
  bool _isProcessing = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0.0;
  String? _apiResponse;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await Future.wait([
      setUserTypeFromFirestore(),
      _initSpeech(),
    ]);
  }

  // Firebase user type fetching
  Future<void> setUserTypeFromFirestore() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('UserID')
            .doc(currentUser.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          setState(() {
            type = (doc.data() as Map)['character_type'] ?? 'ENFJ';
            _gifPath = 'lib/assets/gif/$type/shake_head.gif';
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Error fetching user type: $e');
    }
  }

  // Speech recognition initialization
  Future<void> _initSpeech() async {
    try {
      var status = await Permission.microphone.request();
      if (!status.isGranted) {
        throw Exception('Microphone permission denied');
      }

      _speechEnabled = await _speechToText.initialize(
        onError: (error) => _handleSpeechError(error.errorMsg),
        onStatus: (status) => print('Speech status: $status'),
      );
      setState(() {});
    } catch (e) {
      _handleSpeechError(e.toString());
    }
  }

  // Start listening to speech
  Future<void> _startListening() async {
    if (!_speechEnabled) {
      await _initSpeech();
      if (!_speechEnabled) return;
    }

    setState(() {
      _isListening = true;
      _gifPath = 'lib/assets/gif/$type/wave_hand.gif';
      _wordsSpoken = "";
      _errorMessage = null;
    });

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: 'zh_CN',
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
        listenFor: Duration(seconds: 30),
      );
    } catch (e) {
      _handleSpeechError('Failed to start listening: $e');
    }
  }

  // Stop listening and process speech
  Future<void> _stopListening() async {
    if (!_isListening) return;

    setState(() {
      _isListening = false;
      _isProcessing = true;
    });

    try {
      await _speechToText.stop();
      if (_wordsSpoken.isNotEmpty) {
        await _processRecognizedSpeech(_wordsSpoken);
      }
    } catch (e) {
      _handleSpeechError('Error processing speech: $e');
    } finally {
      setState(() {
        _isProcessing = false;
        _gifPath = 'lib/assets/gif/$type/shake_head.gif';
      });
    }
  }

  // Process recognized speech with LLaMA
  Future<void> _processRecognizedSpeech(String speech) async {
    setState(() {
      _isLoading = true;
      _gifPath = 'lib/assets/gif/$type/jump.gif';
    });

    try {
      final response = await _retryGenerateText(speech);
      if (response != null) {
        setState(() {
          _apiResponse = response;
          _errorMessage = null;
        });

        // Auto-clear response after delay
        Future.delayed(Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              _apiResponse = null;
            });
          }
        });
      } else {
        _handleSpeechError('無法獲取回應');
      }
    } catch (e) {
      _handleSpeechError('處理回應時發生錯誤: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Retry mechanism for LLaMA API calls
  Future<String?> _retryGenerateText(String text, {int maxAttempts = 3}) async {
    for (int i = 0; i < maxAttempts; i++) {
      try {
        final response = await apiService.generateText(text);
        if (response == null) {
          throw Exception('Empty response from API');
        }
        return response;
      } catch (e) {
        if (i == maxAttempts - 1) return null;
        await Future.delayed(Duration(seconds: 1 * (i + 1)));
      }
    }
    return null;
  }

  // Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });
  }

  // Error handling
  void _handleSpeechError(String error) {
    setState(() {
      _errorMessage = error;
      _isListening = false;
      _isProcessing = false;
      _isLoading = false;
      _gifPath = 'lib/assets/gif/$type/shake_head.gif';
    });
    _showErrorDialog(error);
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Text input message handling
  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    _controller.clear();
    await _processRecognizedSpeech(message);
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Home'),
        trailing: IconButton(
          icon: Icon(CupertinoIcons.share),
          onPressed: () => FirebaseAuth.instance.signOut(),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/image/home.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // API Response Display
            if (_apiResponse != null)
              Positioned(
                bottom: 300,
                left: 30,
                right: 180,
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_wordsSpoken.isNotEmpty)
                        Text(
                          '您說: $_wordsSpoken',
                          style: TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 14,
                          ),
                        ),
                      SizedBox(height: 8),
                      Text(
                        _apiResponse!,
                        style: TextStyle(
                          color: CupertinoColors.label,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Character Animation
            Positioned(
              bottom: 100,
              left: 0,
              child: Container(
                width: 400,
                child: Image.asset(_gifPath),
              ),
            ),
            Positioned(
              bottom: 90,
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => AddressSettingsPage()),
                  ),
                  child: Icon(
                    CupertinoIcons.gear_solid,
                    size: 30,
                    color: CupertinoColors.activeBlue,
                  ),
                ),
            ),
            // Location Display
            Positioned(
              top: 100,
              left: 20,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemBackground.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '當前位置:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      locationService.location,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            ..._buildNavigationButtons(),

            // Input Controls
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildInputControls(),
            ),

            // Loading Indicator
            if (_isLoading)
              Center(
                child: CupertinoActivityIndicator(
                  radius: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Navigation Buttons Builder
  List<Widget> _buildNavigationButtons() {
    return [
      _buildNavButton(
        top: 190,
        right: 30,
        width: 130,
        height: 100,
        onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => NotePage()),
        ),
      ),
      _buildNavButton(
        top: 220,
        left: 50,
        width: 130,
        height: 150,
        onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => CalendarPage()),
        ),
      ),
      _buildNavButton(
        top: 450,
        right: 20,
        width: 90,
        height: 80,
        onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => DiaryPage()),
        ),
      ),
    ];
  }

  // Navigation Button Widget
  Widget _buildNavButton({
    required double top,
    double? left,
    double? right,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          color: Colors.transparent,
        ),
      ),
    );
  }

  // Input Controls Builder
  Widget _buildInputControls() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: CupertinoTextField(
                controller: _controller,
                placeholder: "輸入訊息...",
                onSubmitted: (_) => _sendMessage(),
                enabled: !_isLoading && !_isListening,
              ),
            ),
            SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.all(0),
              child: Icon(
                CupertinoIcons.paperplane_fill,
                color: _isLoading ? CupertinoColors.systemGrey : CupertinoColors.activeBlue,
              ),
              onPressed: _isLoading ? null : _sendMessage,
            ),
            CupertinoButton(
              padding: EdgeInsets.all(0),
              child: Icon(
                _isListening ? CupertinoIcons.stop_fill : CupertinoIcons.mic_fill,
                color: _getIconColor(),
              ),
              onPressed: _isLoading ? null : (_isListening ? _stopListening : _startListening),
            ),
          ],
        ),
      ),
    );
  }

  // Get icon color based on state
  Color _getIconColor() {
    if (_isLoading) return CupertinoColors.systemGrey;
    if (_isListening) return CupertinoColors.systemRed;
    return CupertinoColors.activeBlue;
  }
}