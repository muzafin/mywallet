// lib/screens/social_login.dart
import 'package:flutter/material.dart';
import '../common/color_extension.dart';
import '../common_widget/secondary_button.dart';
import '../services/auth_service.dart';

class SocialLoginView extends StatefulWidget {
  const SocialLoginView({super.key});

  @override
  State<SocialLoginView> createState() => _SocialLoginViewState();
}

class _SocialLoginViewState extends State<SocialLoginView> {
  final AuthService _authService = AuthService();
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;
  bool _isFacebookLoading = false;

  // Fungsi Login dengan Google
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        // Kembali ke route awal; authStateChanges di main.dart akan merender HomeScreen.
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login dibatalkan')));
        }
      }
    } catch (e) {
      print('Error login dengan Google: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal login: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // Fungsi untuk Apple Sign In (placeholder)
  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isAppleLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur Apple Sign In segera hadir')),
      );
    }

    setState(() {
      _isAppleLoading = false;
    });
  }

  // Fungsi untuk Facebook Sign In (placeholder)
  Future<void> _handleFacebookSignIn() async {
    setState(() {
      _isFacebookLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur Facebook Sign In segera hadir')),
      );
    }

    setState(() {
      _isFacebookLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/welcome_screen.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    "assets/img/icon_logo_tr.png",
                    width: media.size.width * 0.2,
                    fit: BoxFit.contain,
                  ),
                  const Spacer(),

                  // Tombol Apple Sign In
                  InkWell(
                    onTap: _isAppleLoading ? null : _handleAppleSignIn,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage("assets/img/apple_btn.png"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child:
                          _isAppleLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/img/apple.png",
                                    width: 25,
                                    height: 25,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Sign Up With Apple",
                                    style: TextStyle(
                                      color: TColor.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Tombol Google Sign In (DENGAN FUNGSI LOGIN)
                  InkWell(
                    onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage("assets/img/google_btn.png"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child:
                          _isGoogleLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black87,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/img/gogle.png",
                                    width: 25,
                                    height: 25,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    "Sign Up With Google",
                                    style: TextStyle(
                                      color: TColor.gray,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Tombol Facebook Sign In
                  InkWell(
                    onTap: _isFacebookLoading ? null : _handleFacebookSignIn,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage("assets/img/fb_btn.png"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child:
                          _isFacebookLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/img/fb.png",
                                    width: 25,
                                    height: 25,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Sign Up With Facebook",
                                    style: TextStyle(
                                      color: TColor.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Or",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: TColor.white),
                  ),
                  const SizedBox(height: 20),
                  SecondaryButton(
                    title: "Sign Up With Email",
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur segera hadir')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "By Registering, you agree to our Terms of Service and Privacy Policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: TColor.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
