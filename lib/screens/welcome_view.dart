// lib/screens/welcome_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../common/color_extension.dart';
import '../common_widget/primary_button.dart';
import '../common_widget/secondary_button.dart';
import 'social_login.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Image.asset(
            'assets/img/welcome_screen.png',
            width: media.size.width,
            height: media.size.height,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/img/icon_logo_tr.png",
                    width: media.size.width * 0.2,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    "PAYS",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, color: TColor.white),
                  ),
                  const Spacer(),
                  Text(
                    "Welcome to Pays",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: TColor.white),
                  ),
                  const SizedBox(height: 30),
                  PrimaryButton(
                    title: "Get Started",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SocialLoginView(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  SecondaryButton(
                    title: "I Have an Account",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SocialLoginView(),
                        ),
                      );
                    },
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
