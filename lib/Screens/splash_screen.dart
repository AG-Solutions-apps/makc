import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:makc/Screens/login_page.dart';
import 'package:makc/Utils/shared_pref.dart';
import 'bottom_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _isNavigating = false;
  bool _isVideoPlaying = false;
  int _retryCount = 0;
  static const int maxRetries = 2;
  Timer? _videoCheckTimer;
  Timer? _navigationTimer;
  bool _isInCall = false;
  double _currentVolume = 1.0;
  bool _isInitializing = false;
  bool _hasNavigated = false;
  bool _videoStartedPlaying = false;
  bool _isFirstPlayAttempt = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
    _startNavigationFallback();
  }

  void _startNavigationFallback() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!_hasNavigated && !_isNavigating && mounted) {
        // During call: always navigate if video didn't start playing
        if (_isInCall) {
          if (!_videoStartedPlaying || !_isVideoPlaying) {
            debugPrint('📞 In call - video not playing, navigating after 3 seconds');
            _navigateToNextScreen();
          } else {
            debugPrint('📞 In call - video is playing, continuing');
          }
        } else {
          // Normal: navigate only if video never started
          if (!_videoStartedPlaying) {
            debugPrint('⏱️ 3-second fallback - video never started, navigating');
            _navigateToNextScreen();
          }
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground
      bool wasInCall = _isInCall;
      _isInCall = false;
      _updateVolume();
      
      // If call just ended and video wasn't playing, try to play
      if (wasInCall && _isVideoInitialized && !_isVideoPlaying && !_isNavigating && !_hasNavigated) {
        debugPrint('📞 Call ended - attempting to play video');
        _forcePlayVideo();
      }
      
      // Restart video if needed
      if (_isVideoInitialized && !_isVideoPlaying && !_isNavigating && !_hasNavigated) {
        _forcePlayVideo();
      } else if (!_isVideoInitialized && !_isNavigating && !_isInitializing && !_hasNavigated) {
        _initializeVideo();
      }
    } else if (state == AppLifecycleState.inactive) {
      // App is going to background or call is active
      _isInCall = true;
      _isFirstPlayAttempt = true;
      _updateVolume();
      debugPrint('📞 Call detected - video will be muted');
    }
  }

  void _updateVolume() {
    if (!_isVideoInitialized) return;
    
    double targetVolume = _isInCall ? 0.0 : 1.0;
    
    if (_currentVolume != targetVolume) {
      try {
        _videoController.setVolume(targetVolume);
        _currentVolume = targetVolume;
        debugPrint(_isInCall ? '🔇 Muted (call active)' : '🔊 Volume restored');
      } catch (e) {
        debugPrint('Error updating volume: $e');
      }
    }
  }

  void _initializeVideo() {
    if (_isNavigating || _isInitializing || _hasNavigated) return;
    _isInitializing = true;
    
    try {
      _videoController = VideoPlayerController.asset('assets/spl.mp4')
        ..initialize().then((_) {
          if (mounted && !_isNavigating && !_hasNavigated) {
            setState(() {
              _isVideoInitialized = true;
              _isVideoPlaying = false;
              _isInitializing = false;
            });
            _forcePlayVideo();
            _retryCount = 0;
          } else {
            _isInitializing = false;
          }
        }).catchError((error) {
          debugPrint('❌ Error loading video: $error');
          _isInitializing = false;
          _handleVideoError();
        });
    } catch (e) {
      debugPrint('❌ Exception during video initialization: $e');
      _isInitializing = false;
      _handleVideoError();
    }
  }

  void _forcePlayVideo() {
    if (!_isVideoInitialized || _isNavigating || _hasNavigated) return;
    
    try {
      _videoController.setLooping(false);
      _videoController.play();
      _isVideoPlaying = true;
      
      // Check if video actually started playing
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && !_hasNavigated && !_isNavigating) {
          if (_videoController.value.isPlaying) {
            _videoStartedPlaying = true;
            _navigationTimer?.cancel();
            debugPrint('✅ Video is playing');
          } else {
            debugPrint('⚠️ Video is NOT playing - timer will handle navigation');
            if (_isInCall) {
              // If in call and video not playing, ensure timer will navigate
              _videoStartedPlaying = false;
            }
          }
        }
      });
      
      // Set volume
      _currentVolume = 1.0;
      _updateVolume();
      
      // Remove existing listeners
      _videoController.removeListener(_videoListener);
      _videoController.addListener(_videoListener);
      
      // Start playback check
      _startVideoPlaybackCheck();
      
    } catch (e) {
      debugPrint('❌ Error playing video: $e');
      _handleVideoError();
    }
  }

  void _startVideoPlaybackCheck() {
    _videoCheckTimer?.cancel();
    _videoCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_isNavigating || _hasNavigated) {
        timer.cancel();
        return;
      }
      
      if (_isVideoInitialized) {
        // Check if video ended
        if (_videoController.value.position >= _videoController.value.duration && 
            _videoController.value.duration > Duration.zero) {
          timer.cancel();
          _navigationTimer?.cancel();
          debugPrint('🎬 Video ended - navigating');
          _navigateToNextScreen();
          return;
        }
        
        // If not in call and video stopped, try to restart
        if (!_isInCall && !_videoController.value.isPlaying && _videoStartedPlaying) {
          debugPrint('🔄 Video stopped, restarting...');
          try {
            _videoController.play();
            _isVideoPlaying = true;
          } catch (e) {
            debugPrint('Failed to restart: $e');
          }
        }
      }
    });
  }

  void _videoListener() {
    if (!_isVideoInitialized || _isNavigating || _hasNavigated) return;
    
    // If video ended
    if (_videoController.value.position >= _videoController.value.duration && 
        _videoController.value.duration > Duration.zero) {
      _videoCheckTimer?.cancel();
      _navigationTimer?.cancel();
      debugPrint('🎬 Video ended (listener) - navigating');
      _navigateToNextScreen();
      return;
    }
    
    // If video started playing and we haven't marked it
    if (_videoController.value.isPlaying && !_videoStartedPlaying) {
      _videoStartedPlaying = true;
      _navigationTimer?.cancel();
      debugPrint('✅ Video started playing (listener)');
    }
    
    // Try to play if stopped and not in call
    if (!_isInCall && !_videoController.value.isPlaying && _videoStartedPlaying) {
      try {
        _videoController.play();
        _isVideoPlaying = true;
      } catch (e) {
        debugPrint('Error in listener: $e');
      }
    }
  }

  void _handleVideoError() {
    if (_retryCount < maxRetries && !_isNavigating && !_hasNavigated) {
      _retryCount++;
      debugPrint('🔄 Retry $_retryCount/$maxRetries');
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isNavigating && !_hasNavigated) {
          _initializeVideo();
        }
      });
    } else if (!_isNavigating && !_hasNavigated) {
      debugPrint('❌ Max retries - navigating');
      _navigateToNextScreen();
    }
  }

  Future<void> _navigateToNextScreen() async {
    if (_isNavigating || _hasNavigated) return;
    _isNavigating = true;
    _hasNavigated = true;
    
    _videoCheckTimer?.cancel();
    _navigationTimer?.cancel();
    
    try {
      _videoController.removeListener(_videoListener);
      await _videoController.pause();
    } catch (e) {
      debugPrint('Error cleaning up: $e');
    }
    
    bool login = await SharedPref.isLoggedIn() ?? false;
    if (mounted) {
      debugPrint('🚀 Navigating to: ${login ? "BottomPage" : "LoginPage"}');
      Get.offAll(() => login ? const BottomPage() : const LoginPage());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoCheckTimer?.cancel();
    _navigationTimer?.cancel();
    try {
      _videoController.removeListener(_videoListener);
      _videoController.dispose();
    } catch (e) {
      debugPrint('Error disposing: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: Get.height * 0.65,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    const Text(
                      "WELCOME TO",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                        color: Color.fromARGB(255, 55, 61, 175),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: Get.width * 0.75,
                      height: Get.width * 0.65,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/mac.png"),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Transform Your Living Space  ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    
                    const Spacer(flex: 2),
                    if (!_isVideoInitialized && !_isNavigating && !_hasNavigated)
                      const CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    if (_isInCall && _isVideoInitialized)
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: Get.width * -0.3,
            right: 0,
            height: Get.height * 0.35,
            child: _isVideoInitialized
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}