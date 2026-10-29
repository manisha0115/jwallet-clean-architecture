import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';


class CustomProgressDialog extends StatelessWidget {
  const CustomProgressDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 125.h,
        width: 125.w,
        child: Lottie.asset('assets/animations/loading_animation.json',height: 125,width: 125),
        // child: Lottie.asset('assets/animations/loading_animation.json',height: 125,width: 125),
      ),
    );
  }
}

