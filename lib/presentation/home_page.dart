import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';

import '../infrastructure/service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _phoneNumber = TextEditingController(text: '');
  String? _verificationId;
  Timer? _timer;
  int _seconds = 120;
  bool _otpVerified = false;
  String userId = '';
  bool _loading = false;

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("${MediaQuery.of(context).size}");
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'Phone Authentication',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
            elevation: 0.0,
            iconTheme: IconThemeData(color: Colors.grey.shade800),
            //backgroundColor: Colors.white,
          ),
          body: _bodyUI(),
        ),
        if (_loading) const Center(child: CircularProgressIndicator())
      ],
    );
  }

  Widget _bodyUI() => SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 18.w,
        ),
        child: Column(
          children: [
            SizedBox(
              height: 22.h,
            ),

            ///Instruction
            Text(
              'Provide your phone to OTP verify',
              style: TextStyle(
                color: Colors.grey.shade900,
                fontWeight: FontWeight.w500,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(
              height: 22.h,
            ),

            ///Phone Number
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(5),
                ),
              ),
              child: TextField(
                controller: _phoneNumber,
                maxLength: 11,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Phone Number'),
                readOnly: _verificationId == null ? false : true,
              ),
            ),
            SizedBox(
              height: 22.h,
            ),

            if (_verificationId != null)
              Column(children: [
                Pinput(
                  onCompleted: (value) async {
                    _otpVerification(value);
                  },
                  length: 6,
                  showCursor: true,
                  defaultPinTheme: KPinTheme.defaultPinTheme,
                  focusedPinTheme: KPinTheme.focusedPinTheme,
                  submittedPinTheme: KPinTheme.submittedPinTheme,
                ),
                SizedBox(
                  height: 15.sp,
                ),
                Center(
                  child: _otpVerified
                      ? Text(
                          'Phone Number Verified',
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Text(
                          'OTP will resend after $_seconds sec',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade900,
                          ),
                        ),
                ),
              ]),

            if (_verificationId == null)
              ElevatedButton(
                onPressed: () {
                  if (_phoneNumber.text.isNotEmpty) {
                    if (_phoneNumber.text.length == 11) {
                      NotificationService.sendNotification();
                      _phoneAuth();
                    } else {
                      showToast('Invalid phone number');
                    }
                  } else {
                    showToast('Provide phone number');
                  }
                },
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Get OTP',
                        style: TextStyle(
                          fontSize: 14.sp,
                        ),
                      ),
              ),
            SizedBox(
              height: 30.h,
            ),

            SizedBox(
              height: 14.h,
            ),
          ],
        ),
      );

  Future<void> _phoneAuth() async {
    setState(() => _loading = true);
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: '+88' + _phoneNumber.text,

      ///Auto Verification
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) async {
          if (value.user != null) {
            setState(() {
              _loading = false;
              _otpVerified = true;
            });
            showToast('Phone number verified');
            await NotificationService.sendNotification();
          } else {
            setState(() => _loading = false);
            showToast('Verification Failed! Try again');
          }
        });
      },

      ///Verification Failed
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          setState(() {
            _loading = false;
          });
          showToast('The provided phone number is not valid');
        }
      },

      ///Verify with  OTP
      codeSent: (String verificationId, int? resendToken) async {
        setState(() {
          _loading = false;
          _verificationId = verificationId;
          _startTimer();
        });
      },
      // timeout: const Duration(seconds: 120),
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          showToast('OTP resend');
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _otpVerification(otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!, smsCode: otp);
    setState(() => _loading = true);
    // Sign the user in (or link) with the credential
    try {
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) async {
        if (value.user != null) {
          setState(() {
            _loading = false;
            _otpVerified = true;
          });
          _timer!.cancel();
          await NotificationService.sendNotification();
        } else {
          setState(() {
            _loading = false;
            _otpVerified = false;
            _verificationId == null;
          });
          showToast('Invalid OTP');
        }
      });
    } on FirebaseException catch (e) {
      setState(() {
        _loading = false;
        _otpVerified = false;
        _verificationId == null;
      });
      showToast(e.message.toString());
      debugPrint(e.toString());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_seconds < 1) {
            timer.cancel();
          } else {
            if (_seconds >= 0) {
              setState(() => _seconds = _seconds - 1);
            }
            if (_seconds == 0) {
              _timer!.cancel();
            }
          }
        },
      ),
    );
  }

  void showToast(String mgs) => Fluttertoast.showToast(
        msg: mgs,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.sp,
      );
}

class KPinTheme {
  static var defaultPinTheme = PinTheme(
    height: 40.h,
    width: 40.w,
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.grey,
      ),
      borderRadius: BorderRadius.circular(
        6.r,
      ),
    ),
  );

  static var submittedPinTheme = defaultPinTheme.copyDecorationWith(
    border: Border.all(color: Colors.green),
    borderRadius: BorderRadius.circular(
      10.r,
    ),
  );
  static var focusedPinTheme = defaultPinTheme.copyDecorationWith(
    border: Border.all(
      color: Colors.blue,
    ),
    borderRadius: BorderRadius.circular(
      10.r,
    ),
  );
}
