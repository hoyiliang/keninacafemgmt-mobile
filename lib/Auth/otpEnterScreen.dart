import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'newPasswordScreen.dart';

void main() {
  runApp(const MyApp());
}

void enterFullScreen() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const OtpEnterScreenPage(otp: null, uid: null, remainingTime: null),
    );
  }
}

class OtpEnterScreenPage extends StatefulWidget {
  const OtpEnterScreenPage({super.key, this.otp, this.uid, this.remainingTime});

  final String? otp;
  final String? uid;
  final int? remainingTime;

  @override
  State<OtpEnterScreenPage> createState() => _OtpEnterScreenPageState();
}

class _OtpEnterScreenPageState extends State<OtpEnterScreenPage> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Timer _timer;
  int _timeoutInSeconds = 0;
  int _remainingTime = 0;

  String? getOTP() {
    return widget.otp;
  }

  String? getUidEncode() {
    return widget.uid;
  }

  int? getRemainingTime() {
    return widget.remainingTime;
  }

  @override
  void initState() {
    super.initState();
    _timeoutInSeconds = getRemainingTime()!;
    _remainingTime = getRemainingTime()!;
    _startTimer();
  }

  void _startTimer() {
    // _timer = Timer(Duration(seconds: _timeoutInSeconds), () {
    //   // Timeout logic
    //   Navigator.pop(context); // Go back to the login page
    // });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          print(_remainingTime);
        } else {
          _timer.cancel(); // Stop the timer when it reaches 0
          Navigator.pop(context); // Go back to the login page
        }
      });
    });
  }

  void _resetTimer() {
    _timer.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  onGoBack(dynamic value) {
    setState(() {
      otpController.text = "";
    });
  }

  void navigateNewPasswordScreenPage(String uidEncode, int remainingTime){
    Route route = MaterialPageRoute(builder: (context) => NewPasswordScreenPage(uid: uidEncode, remainingTime: remainingTime,));
    Navigator.push(context, route).then(onGoBack);
  }

  @override
  Widget build(BuildContext context) {

    String? otp = getOTP();
    String? uidEncode = getUidEncode();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter OTP',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => {
            Navigator.of(context).pop(),
          },
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
        ),
        backgroundColor: Colors.deepPurple.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Time remaining: ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15.0,),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                  child: Row(
                      children: [
                        Text('OTP number', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                        // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                      ]
                  )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child:
                TextFormField(
                  controller: otpController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your otp (OTP number have sent to your email).';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), // Set border radius here
                      borderSide: BorderSide(
                        color: Colors.grey.shade500,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), // Set border radius here
                      borderSide: BorderSide(
                        color: Colors.grey.shade500,
                        width: 2.0,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), // Set border radius here
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), // Set border radius here
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 2.0,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    // hintText: 'Please enter your password',
                  ),
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gabarito",
                  ),
                ),
              ),
              const SizedBox(height: 13,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                child: Container(
                  padding: const EdgeInsets.only(top: 3,left: 3),
                  child: MaterialButton(
                    minWidth: double.infinity,
                    height:50,
                    onPressed: (){
                      if (_formKey.currentState!.validate()) {
                        if (otp.toString() == otpController.text) {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => NewPasswordScreenPage(uid: uidEncode, remainingTime: _remainingTime)),
                          // );
                          navigateNewPasswordScreenPage(uidEncode!, _remainingTime);
                        } else {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Error'),
                              content: const Text('OTP validation failed.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    color: Colors.greenAccent.shade400,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)
                    ),
                    child: const Text("Validate",style:
                    TextStyle(
                      fontWeight: FontWeight.bold,fontSize: 16, color: Colors.white,
                    ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
