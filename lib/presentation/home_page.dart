import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_phone_auth/presentation/otp_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';

import '../infastructure/service.dart';
import '../widgets/show_toast.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _phoneNumber = TextEditingController(text: '');

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
          body: SingleChildScrollView(
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
                    // readOnly: _verificationId == null ? false : true,
                  ),
                ),
                SizedBox(
                  height: 22.h,
                ),

                ElevatedButton(
                  onPressed: () {
                    if (_phoneNumber.text.isNotEmpty) {
                      if (_phoneNumber.text.length == 11) {
                        NotificationService.sendNotification();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OtpPage(phone: _phoneNumber.text),
                          ),
                        );
                      } else {
                        showToast('Invalid phone number');
                      }
                    } else {
                      showToast('Provide phone number');
                    }
                  },
                  child: Text(
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
          ),
        ),
      ],
    );
  }
}
