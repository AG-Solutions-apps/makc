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

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset('assets/spl.mp4')
      ..initialize().then((_) {
        setState(() => _isVideoInitialized = true);
        _videoController.setLooping(false); // Set to false to trigger listener at end
        _videoController.play();
        _videoController.addListener(_videoListener);
      }).catchError((error) {
        debugPrint('Error loading video: $error');
        _navigateToNextScreen();
      });
  }

  void _videoListener() {
    // Check if the video is at the end
    if (_videoController.value.position >= _videoController.value.duration) {
      _navigateToNextScreen();
    }
  }

  Future<void> _navigateToNextScreen() async {
    _videoController.removeListener(_videoListener);
    bool login = await SharedPref.isLoggedIn() ?? false;
    if (mounted) {
      Get.offAll(() => login ? const BottomPage() : const LoginPage());
    }
  }

  @override
  void dispose() {
    _videoController.removeListener(_videoListener);
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: Stack(
        children: [
          // --- TOP SECTION: Perfectly Centered Content (Takes top 65% of screen) ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: Get.height * 0.65,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity, // Forces the column to span full width for proper centering
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    // 1. "WELCOME TO" Text
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
                    
                    // 2. App Logo with subtle shadow for premium UI/UX
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
                    
                    // 3. "MAKc Solutions" Text
                    
                    const Text(
                      "Transform Your Living Space with ",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.5,
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),

                    const Text(
                      "MAKc Automation",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Color.fromARGB(255, 55, 61, 175),
                      ),
                    ),
                    
                    const Spacer(flex: 2),
                    
                    // Loading Indicator just above the video
                    
                    
                  ],
                ),
              ),
            ),
          ),

          // --- BOTTOM SECTION: Auto-Play Video (Takes bottom 35% of screen) ---
         Positioned(
  bottom: 30, // Space from bottom
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
        ),
),
        ],
      ),
    );
  }
}