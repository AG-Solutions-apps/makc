import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makc/Controller/controller.dart';
import 'package:makc/Utils/api_helper.dart';
import 'package:makc/Utils/loader.dart';
import 'package:makc/Screens/signup_page.dart';
import 'package:makc/Screens/otp_verification_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController txtMobile = TextEditingController();
  final GlobalKey<FormState> key = GlobalKey<FormState>();
  final Controller controller = Get.put(Controller());
  
  // Added FocusNode to track when the text field is selected
  final FocusNode _mobileFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    txtMobile.clear();
    
    // Listen for focus changes to trigger the glow rebuild
    _mobileFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _mobileFocusNode.dispose();
    txtMobile.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!key.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    Loader.showLoader(context, "Checking mobile status...");

    final mobileNum = txtMobile.text.trim();

    try {
      final checkResponse = await ApiHelper.apiHelper.checkMobile(mobile: mobileNum);
      
      if (checkResponse == null) {
        if (!mounted) return;
        Loader.hideLoader(context);
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to connect to the server."), backgroundColor: Colors.red),
        );
        return;
      }

      if (checkResponse["code"] == 401 || (checkResponse["message"] != null && checkResponse["message"].toString().toLowerCase().contains("not registered"))) {
        if (!mounted) return;
        Loader.hideLoader(context);
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(checkResponse["message"] ?? "Mobile not registered. Please sign up."),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: "SIGN UP",
              textColor: Colors.white,
              onPressed: () {
                Get.to(() => const SignupPage(), transition: Transition.fadeIn);
              },
            ),
          ),
        );
        return;
      }

      if (checkResponse["code"] != 200) {
        if (!mounted) return;
        Loader.hideLoader(context);
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(checkResponse["message"] ?? "Something went wrong."), backgroundColor: Colors.red),
        );
        return;
      }

      final password = checkResponse["data"] ?? "";
      
      if (!mounted) return;
      Loader.hideLoader(context);
      Loader.showLoader(context, "Sending OTP...");

      String formattedMobile = mobileNum;
      if (!formattedMobile.startsWith("+")) {
        formattedMobile = "+91$formattedMobile";
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedMobile,
        verificationCompleted: (PhoneAuthCredential credential) async {
  print("AUTO VERIFICATION TRIGGERED - LOGIN");
},
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          Loader.hideLoader(context);
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Verification failed. Please try again."), backgroundColor: Colors.red),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          Loader.hideLoader(context);
          setState(() => _isLoading = false);
          
          Get.to(
            () => OtpVerificationPage(
              verificationId: verificationId,
              mobile: mobileNum,
              isSignup: false,
              loginPassword: password,
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
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildSocialBtn(Widget icon) {
    return Expanded(
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFF0F1522),
          border: Border.all(color: const Color(0xFF1E253A), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: key,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFF060B15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color.fromARGB(255, 28, 62, 138).withOpacity(0.9), 
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF031B50).withOpacity(0.55), 
                      blurRadius: 60,
                      spreadRadius: 15,
                    ),
                    BoxShadow(
                      color: const Color(0xFF0056FF).withOpacity(0.3), 
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        height: Get.width / 1.9,
                        width: Get.width / 1.5,
                        decoration: const BoxDecoration(color: Colors.transparent),
                        child: Image.asset("assets/mac.png", fit: BoxFit.contain),
                      ),
                    ),
                  
                    const Text(
                      "Sign in to your account",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Manage your smart home, anywhere.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                    ),
                    const SizedBox(height: 80),
                    const Text(
                      "Mobile Number",
                      style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    // TEXT FIELD GLOW WRAPPER
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _mobileFocusNode.hasFocus 
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
                        controller: txtMobile,
                        focusNode: _mobileFocusNode, // Attach focus node here
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF0F1522),
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
                          hintText: "Enter your mobile no",
                          hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 14),
                          prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF9CA3AF), size: 20),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Please enter the mobile no";
                          if (value.length < 10) return "Please enter a valid 10-digit mobile no";
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Color(0xFF0066FF), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0061FF), Color(0xFF0044CC)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            if (!_isLoading) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                            ],
                            if (_isLoading) ...[
                              const SizedBox(width: 12),
                              const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            ]
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 35),
                    
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
                        GestureDetector(
                          onTap: _isLoading ? null : () => Get.to(() => const SignupPage(), transition: Transition.fadeIn),
                          child: const Text("Sign up", style: TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.w600, fontSize: 14)),
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