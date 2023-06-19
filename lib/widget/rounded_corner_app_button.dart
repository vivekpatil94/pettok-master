import 'package:flutter/material.dart';
import 'package:acoustic/util/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoundedCornerAppButton extends StatelessWidget {
  RoundedCornerAppButton({required this.btnLabel, required this.onPressed});
  final btnLabel;
  final Function onPressed;

  @override
 Widget build(BuildContext context) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      elevation: 5.0,
      textStyle: TextStyle(
        color: Colors.white,
      ),
      primary: Color(Constants.buttonbg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    onPressed: onPressed as void Function()?,
    child: Container(
      height: ScreenUtil().setHeight(50),
      alignment: Alignment.center,
      child: Text(
        btnLabel,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: Constants.appFont,
          fontWeight: FontWeight.w900,
          fontSize: 16.0,
        ),
      ),
    ),
  );
}
}
