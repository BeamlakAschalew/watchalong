//import 'package:animated_text_kit/animated_text_kit.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'package:flutter/material.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    // void updateFirstRunData() async {
    //   final prefs = await SharedPreferences.getInstance();
    //   await prefs.setBool('isFirstRun', false);
    // }

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          height: deviceHeight,
          width: deviceWidth,
          decoration: const BoxDecoration(color: Color(0xFFE62E04)),
          child: Container(
            decoration: const BoxDecoration(
              // color: Colors.black.withOpacity(0.5),
              gradient: LinearGradient(
                colors: [Color(0xff000000), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    height: 400,
                    width: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                        child: SizedBox(
                      width: 250.0,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 30.0,
                          fontFamily: 'PoppinsBold',
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 75,
                              child: Padding(
                                  padding: EdgeInsets.only(top: 5.0),
                                  child: Text('WatchAlong')),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10.0),
                              child: Text(
                                'Have fun with your friends',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    //  crossAxisAlignment: WrapCrossAlignment.start,
                    // spacing: 10,
                    children: [
                      ElevatedButton(
                          style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  const Size(150, 50)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xFFeb4034))),
                          onPressed: () async {
                            // updateFirstRunData();
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const LoginScreen();
                            }));
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(color: Colors.white),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              minimumSize: MaterialStateProperty.all(
                                  const Size(150, 50)),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white)),
                          onPressed: () async {
                            // updateFirstRunData();
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const SignupScreen();
                            }));
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.black),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // TypewriterAnimatedText animatedTextWIdget(
  //     {required String textTitle,
  //     required int animationDuration,
  //     required double fontSize}) {
  //   return TypewriterAnimatedText(textTitle,
  //       speed: Duration(milliseconds: animationDuration),
  //       textStyle: TextStyle(
  //         fontSize: fontSize,
  //       ),
  //       textAlign: TextAlign.center);
  // }
}
