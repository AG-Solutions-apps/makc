import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makc/Utils/api_helper.dart';
import 'package:makc/Utils/loader.dart';
import 'package:makc/Screens/otp_verification_page.dart';
import 'package:makc/Screens/login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController txtName = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtMobile = TextEditingController();
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  
  // Focus nodes for the text field glow effect
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _mobileFocusNode = FocusNode();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    txtName.clear();
    txtEmail.clear();
    txtMobile.clear();
    
    // Add listeners to trigger glow effect when fields are focused
    _nameFocusNode.addListener(() { if (mounted) setState(() {}); });
    _emailFocusNode.addListener(() { if (mounted) setState(() {}); });
    _mobileFocusNode.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _mobileFocusNode.dispose();
    txtName.dispose();
    txtEmail.dispose();
    txtMobile.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!key.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    Loader.showLoader(context, "Checking mobile status...");

    final nameNum = txtName.text.trim();
    final emailNum = txtEmail.text.trim();
    final mobileNum = txtMobile.text.trim();

    try {
      // 1. Check if the mobile is already registered
      final checkResponse = await ApiHelper.apiHelper.checkMobile(mobile: mobileNum);

      if (checkResponse == null) {
        if (!mounted) return;
        Loader.hideLoader(context);
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to connect to the server."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // If code == 200, user is already registered!
      if (checkResponse["code"] == 200) {
        if (!mounted) return;
        Loader.hideLoader(context);
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Mobile number already registered. Please login."),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: "LOGIN",
              textColor: Colors.white,
              onPressed: () {
                Get.offAll(() => const LoginPage(), transition: Transition.fadeIn);
              },
            ),
          ),
        );
        return;
      }

      // If 401 or not registered, proceed to Firebase OTP
      if (!mounted) return;
      Loader.hideLoader(context);
      Loader.showLoader(context, "Sending OTP...");

      String formattedMobile = mobileNum;
      if (!formattedMobile.startsWith("+")) {
        formattedMobile = "+91$formattedMobile";
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
       verificationCompleted: (PhoneAuthCredential credential) async {
  print("AUTO VERIFICATION TRIGGERED - SIGNUP");
},
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          Loader.hideLoader(context);
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? "Verification failed. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          Loader.hideLoader(context);
          setState(() {
            _isLoading = false;
          });

          Get.to(
            () => OtpVerificationPage(
              verificationId: verificationId,
              mobile: mobileNum,
              isSignup: true,
              signupName: nameNum,
              signupEmail: emailNum,
            ),
            transition: Transition.fadeIn,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      if (!mounted) return;
      Loader.hideLoader(context);
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper widget to build consistent input fields WITH GLOW
  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD1D5DB), // Light gray label
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: focusNode.hasFocus 
              ? [
                  BoxShadow(
                    color: const Color(0xFF0056FF).withOpacity(0.4), // The text field glow
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ] 
              : [],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F1522), // Dark input background
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF1E253A)),
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF1E253A)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF0056FF), width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 14), // Darker gray hint
              prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02040A), // Extremely dark blue/black ambient background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: key,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                padding: const EdgeInsets.only(left: 24, right: 24, top: 30, bottom: 30),
                
                // --- ENHANCED MAIN CONTAINER GLOW ---
                decoration: BoxDecoration(
                  color: const Color(0xFF060B15), // Deep card background
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF1C3E8A).withOpacity(0.9), // Brighter border line
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1C3E8A).withOpacity(0.55), // Wide outer glow
                      blurRadius: 60,
                      spreadRadius: 15,
                    ),
                    BoxShadow(
                      color: const Color(0xFF0056FF).withOpacity(0.3), // Tighter inner glow
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ORIGINAL LOGO
                    
                    Center(
                      child: Container(
                         height: Get.width / 1.9,
                        width: Get.width / 1.5,
                        decoration: const BoxDecoration(color: Colors.transparent),
                        child: Image.asset("assets/mac.png", fit: BoxFit.contain),
                      ),
                    ),
                
                    
                    // Headings
                    const Text(
                      "Sign Up",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Create an account to get started",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9CA3AF), // Soft gray
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Inputs
                    _buildInputField(
                      controller: txtName,
                      focusNode: _nameFocusNode,
                      label: "Full Name",
                      hint: "Enter your full name",
                      icon: Icons.person,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter your full name";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInputField(
                      controller: txtEmail,
                      focusNode: _emailFocusNode,
                      label: "Email ID (Optional)",
                      hint: "Enter your email address",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInputField(
                      controller: txtMobile,
                      focusNode: _mobileFocusNode,
                      label: "Mobile Number",
                      hint: "Enter your 10 digit mobile no",
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the mobile no";
                        }
                        if (value.length < 10) {
                          return "Please enter a valid 10-digit mobile no";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 35),

                    // Sign Up Button exactly matched
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF0061FF), // Bright blue top
                            Color(0xFF0044CC), // Deeper blue bottom
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!_isLoading) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                            if (_isLoading) ...[
                              const SizedBox(width: 12),
                              const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),

                    // Footer Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                                  Get.offAll(() => const LoginPage(), transition: Transition.fadeIn);
                                },
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: Color(0xFF0066FF), // Exact bright blue
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}