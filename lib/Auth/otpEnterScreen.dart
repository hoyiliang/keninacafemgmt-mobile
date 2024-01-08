import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/Auth/passwordResetScreen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Utils/error_codes.dart';
import '../Utils/ip_address.dart';
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
      home: const OtpEnterScreenPage(otp_id: null, uid: null),
    );
  }
}

class OtpEnterScreenPage extends StatefulWidget {
  const OtpEnterScreenPage({super.key, this.otp_id, this.uid});

  final String? otp_id;
  final String? uid;

  @override
  State<OtpEnterScreenPage> createState() => _OtpEnterScreenPageState();
}

class _OtpEnterScreenPageState extends State<OtpEnterScreenPage> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Timer _otpTimer;
  late Timer _resendEmailTimer;
  // int _timeoutInSeconds = 0;
  int _remainingOTPTime = 0;
  int _remainingResendEmailTime = 0;
  bool isLoading = false;
  bool isLoadingVerify = false;
  String? otpIdGet;

  String? getOTPId() {
    return widget.otp_id;
  }

  String? getUidEncode() {
    return widget.uid;
  }

  @override
  void initState() {
    super.initState();
    otpIdGet = getOTPId();
    _remainingOTPTime = 300;
    _remainingResendEmailTime = 60;
    _startOTPTimer();
    _startResendEmailTimer();
  }

  void _startOTPTimer() {
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingOTPTime > 0) {
          _remainingOTPTime--;
        } else {
          _otpTimer.cancel();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PasswordResetScreenPage()),
          );
          showDialog(context: context, builder: (
              BuildContext context) =>
              AlertDialog(
                title: const Text('Timeout', style: TextStyle(fontWeight: FontWeight.bold,)),
                content: const Text('OTP Verification Timeout'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Ok'),
                    onPressed: () {
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
          );
        }
      });
    });
  }

  void _startResendEmailTimer() {
    _resendEmailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingResendEmailTime > 0) {
          _remainingResendEmailTime--;
        } else {
          _resendEmailTimer.cancel(); // Stop the timer when it reaches 0
        }
      });
    });
  }

  void _resetTimer() {
    _otpTimer.cancel();
    _resendEmailTimer.cancel();
    _remainingOTPTime = 300;
    _remainingResendEmailTime = 60;
    _startOTPTimer();
    _startResendEmailTimer();
  }

  @override
  void dispose() {
    _otpTimer.cancel();
    _resendEmailTimer.cancel();
    super.dispose();
  }

  onGoBack(dynamic value) {
    setState(() {
      otpController.text = "";
    });
  }

  void navigateNewPasswordScreenPage(String uidEncode){
    Route route = MaterialPageRoute(builder: (context) => NewPasswordScreenPage(uid: uidEncode));
    Navigator.push(context, route).then(onGoBack);
  }

  @override
  Widget build(BuildContext context) {

    String? currentOtpId = getOTPId();
    String? uidEncode = getUidEncode();

    return WillPopScope(
      onWillPop: () async {
        _otpTimer.cancel();
        _resendEmailTimer.cancel();
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: const Text(
            'Verify your email',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () => {
              _resendEmailTimer.cancel(),
              _otpTimer.cancel(),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'OTP will expire in: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_remainingOTPTime ~/ 60}:${(_remainingOTPTime % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          var (success, err_code) = await verifyOtp(otpController.text, currentOtpId!);
                          if (err_code == ErrorCodes.OPERATION_OK) {
                            setState(() {
                              isLoadingVerify = false;
                              otpController.text = "";
                              _otpTimer.cancel();
                              _resendEmailTimer.cancel();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => NewPasswordScreenPage(uid: uidEncode,),
                                  ));
                            });
                          } else {
                            setState(() {
                              isLoadingVerify = false;
                            });
                            if (err_code == ErrorCodes.VERIFY_OTP_FAIL_BACKEND) {
                              showDialog(context: context, builder: (
                                  BuildContext context) =>
                                  AlertDialog(
                                    title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                                    content: Text('An Error occurred while trying to verify otp.\n\nError Code: $err_code'),
                                    actions: <Widget>[
                                      TextButton(onPressed: () =>
                                          Navigator.pop(context, 'Ok'),
                                          child: const Text('Ok')
                                      ),
                                    ],
                                  ),
                              );
                            } else if (err_code == ErrorCodes.VERIFY_OTP_FAIL_NOT_MATCHED) {
                              showDialog(context: context, builder: (
                                  BuildContext context) =>
                                  AlertDialog(
                                    title: const Text('Verification Failed', style: TextStyle(fontWeight: FontWeight.bold,)),
                                    content: Text('Please check your email with otp number.\n\nError Code: $err_code'),
                                    actions: <Widget>[
                                      TextButton(onPressed: () =>
                                          Navigator.pop(context, 'Ok'),
                                          child: const Text('Ok')
                                      ),
                                    ],
                                  ),
                              );
                            } else if (err_code == ErrorCodes.VERIFY_OTP_FAIL_API_CONNECTION) {
                              showDialog(context: context, builder: (
                                  BuildContext context) =>
                                  AlertDialog(
                                    title: const Text('Connection Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                                    content: Text(
                                        'Unable to establish connection to our services. Please make sure you have an internet connection.\n\nError Code: $err_code'),
                                    actions: <Widget>[
                                      TextButton(onPressed: () =>
                                          Navigator.pop(context, 'Ok'),
                                          child: const Text('Ok')),
                                    ],
                                  ),
                              );
                            }
                          }
                        }
                      },
                      color: Colors.greenAccent.shade400,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: isLoadingVerify
                          ? LoadingAnimationWidget.threeRotatingDots(
                        color: Colors.black,
                        size: 20,
                      )
                          : const Text("Verify",style:
                      TextStyle(
                        fontWeight: FontWeight.bold,fontSize: 16, color: Colors.white,
                      ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 13.0,),
                const Text(
                  "Didn't receive an email?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5.0,),
                TextButton(
                  onPressed: () async {
                    if (_remainingResendEmailTime == 0) {
                      var (otpLatest, err_code) = await resendEmail(uidEncode!, currentOtpId!);
                      if (err_code == ErrorCodes.OPERATION_OK) {
                        setState(() {
                          isLoading = false;
                          otpIdGet = otpLatest;
                          _resetTimer();
                        });
                      } else {

                        if (err_code == ErrorCodes.RESEND_EMAIL_FAIL_BACKEND) {
                          showDialog(context: context, builder: (
                              BuildContext context) =>
                              AlertDialog(
                                title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                                content: Text('An Error occurred while trying to resend the email with otp.\n\nError Code: $err_code'),
                                actions: <Widget>[
                                  TextButton(onPressed: () =>
                                      Navigator.pop(context, 'Ok'),
                                      child: const Text('Ok')),
                                ],
                              ),
                          );
                        } else if (err_code == ErrorCodes.RESEND_EMAIL_FAIL_API_CONNECTION) {
                          showDialog(context: context, builder: (
                              BuildContext context) =>
                              AlertDialog(
                                title: const Text('Connection Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                                content: Text(
                                    'Unable to establish connection to our services. Please make sure you have an internet connection.\n\nError Code: $err_code'),
                                actions: <Widget>[
                                  TextButton(onPressed: () =>
                                      Navigator.pop(context, 'Ok'),
                                      child: const Text('Ok')),
                                ],
                              ),
                          );
                        }
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(50, 15),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Try again ",
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (_remainingResendEmailTime > 0)
                        Text(
                          '(${(_remainingResendEmailTime).toString().padLeft(2, '0')})',
                          style: TextStyle(
                            fontSize: 15,
                            // fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      if (isLoading)
                          LoadingAnimationWidget.threeRotatingDots(
                        color: Colors.black,
                        size: 20,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<(String, String)> resendEmail(String uidEncode, String otp_id) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('${IpAddress.ip_addr}/users/resend_email'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'uidEncode': uidEncode,
          'current_otp_id': otp_id,
        }),

      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return (responseData['otp'].toString(), (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('Failed to resend email.');
        }
        return ("", (ErrorCodes.RESEND_EMAIL_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return ("", (ErrorCodes.RESEND_EMAIL_FAIL_API_CONNECTION));
    }
  }

  Future<(bool, String)> verifyOtp(String otpEnter, String currentOtpId) async {
    setState(() {
      isLoadingVerify = true;
    });
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/users/verify_otp_number'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'otp_number': otpEnter,
          'current_otp_id': currentOtpId,
        }),

      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        final responseData = json.decode(response.body);
        if (responseData['error'] == "OTP is not matched.") {
          return (false, (ErrorCodes.VERIFY_OTP_FAIL_NOT_MATCHED));
        }
        if (kDebugMode) {
          print('Failed to verify otp.');
        }
        return (false, (ErrorCodes.VERIFY_OTP_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.VERIFY_OTP_FAIL_API_CONNECTION));
    }
  }
}
