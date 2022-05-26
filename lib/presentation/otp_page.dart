import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';

import '../infrastructure/service.dart';
import '../widgets/show_toast.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({
    Key? key,
    required this.phone,
  }) : super(key: key);

  final String phone;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String? _verificationId;

  Timer? _timer;

  int _seconds = 120;

  bool _otpVerified = false;

  String userId = '';

  bool _loading = false;

  @override
  void initState() {
    _phoneAuth();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP"),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Pinput(
              onCompleted: (value) async {
                _otpVerification(value);
              },
              length: 6,
              showCursor: true,
              defaultPinTheme: StaticDecoration.defaultPinTheme,
              focusedPinTheme: StaticDecoration.focusedPinTheme,
              submittedPinTheme: StaticDecoration.submittedPinTheme,
            ),
            SizedBox(
              height: 15.sp,
            ),
            _otpVerified
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
            SizedBox(
              height: 30.h,
            ),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink(),
            SizedBox(
              height: 100.h,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _phoneAuth() async {
    setState(() => _loading = true);
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: '+88' + widget.phone,

      ///Auto Verification
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential).then((value) async {
          if (value.user != null) {
            setState(() => _loading = false);
            setState(() => _otpVerified = true);
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
          setState(() => _loading = false);
          showToast('The provided phone number is not valid');
        }
      },

      ///Verify with  OTP
      codeSent: (String verificationId, int? resendToken) async {
        _loading = false;
        _verificationId = verificationId;
        setState(() {});
        _startTimer();
      },
      timeout: const Duration(seconds: 120),
      codeAutoRetrievalTimeout: (String verificationId) {
        showToast('OTP resend');
        _verificationId = verificationId;
        setState(() {});
      },
    );
  }

  Future<void> _otpVerification(otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!, smsCode: otp);
    setState(() => _loading = true);
    // Sign the user in (or link) with the credential
    await FirebaseAuth.instance
        .signInWithCredential(credential)
        .then((value) async {
      if (value.user != null) {
        setState(() => _loading = false);
        setState(() => _otpVerified = true);
        _timer!.cancel();
        await NotificationService.sendNotification();
      } else {
        setState(() => _loading = false);
        setState(() => _otpVerified = false);
        showToast('Invalid OTP');
      }
    });
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
}

class StaticDecoration {
  static var defaultPinTheme = PinTheme(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ));

  static var submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.green),
      borderRadius: BorderRadius.circular(10));
  static var focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.blue),
      borderRadius: BorderRadius.circular(10));
}
