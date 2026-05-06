import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

class FlatButton extends StatelessWidget {
  String title;
  Color? backgroundColor;
  Color? disabledBackgroundColor;
  Color? foregroundColor;
  VoidCallback? onPressed;
  bool isWrapWidth;
  double borderRadius;
  double titleSize;
  bool isBold;
  Widget? leadingIcon;
  Widget? tailingIcon;
  EdgeInsetsGeometry? padding;
  bool isSizedFit;
  bool enabled;
  FlatButton(this.title, {this.foregroundColor, this.backgroundColor, this.disabledBackgroundColor, this.onPressed, this.isWrapWidth = false, this.borderRadius = 10, this.titleSize = 15, this.isBold = false, this.leadingIcon, this.tailingIcon, this.isSizedFit = false, this.enabled = true, this.padding, super.key});

  @override
  Widget build(BuildContext context) {
    if(isWrapWidth) {
      return Container(
        decoration: BoxDecoration(
          color: backgroundColor != null ? (enabled ? backgroundColor : disabledBackgroundColor) : AppColors.blue,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? AppColors.white,
            padding: padding ?? const EdgeInsets.all(15.0),
            // minimumSize: Size.zero,
            tapTargetSize: isSizedFit ? MaterialTapTargetSize.shrinkWrap : null,
            textStyle: TextStyle(
                fontSize: titleSize,
                fontWeight: isBold ? FontWeight.bold : null,
                fontFamily: 'Ubuntu'
            ),
          ),
          onPressed: (onPressed != null && enabled) ? onPressed : () {},
          child: (leadingIcon != null || tailingIcon != null) ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null)
                ...[
                  leadingIcon!,
                  const SizedBox(width: 5,),
                ],
              Text(title),
              if (tailingIcon != null)
                ...[
                  const SizedBox(width: 5,),
                  tailingIcon!
                ]
            ],
          ) : Text(title),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.blue,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? AppColors.white,
            padding: const EdgeInsets.all(15.0),
            textStyle: TextStyle(
                fontSize: titleSize,
                fontWeight: isBold ? FontWeight.bold : null,
                fontFamily: 'Ubuntu'
            )
          ),
          onPressed: onPressed ?? () {},
          child: leadingIcon != null ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              leadingIcon!,
              const SizedBox(width: 10,),
              Text(title)
            ],
          ) : Text(title),
        ),
      );
    }
  }

}