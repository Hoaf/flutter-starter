import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../config/app_colors.dart';

class DrawerItem extends StatelessWidget {
  String title;
  String assetPath;
  VoidCallback? onPress;
  bool isActive;
  Widget? tailingIcon;
  double? iconSize;
  DrawerItem({
    required this.title,
    required this.assetPath,
    this.isActive = false,
    this.onPress,
    this.tailingIcon,
    this.iconSize = 24,
    super.key
  });

  final double _drawerHeight = 60;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {onPress?.call()},
        child: Container(
          height: _drawerHeight,
          padding: const EdgeInsets.all(15),
          color: isActive ? AppColors.white : AppColors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(assetPath, width: iconSize, height: iconSize, color: isActive ? AppColors.appBarBackgroundColor : AppColors.white,),
                  const SizedBox(width: 10,),
                  Text(title,
                    style: TextStyle(color: isActive ? AppColors.appBarBackgroundColor : AppColors.white, fontSize: 18,),),
                ],
              ),
              tailingIcon ?? Container(),
              // const SizedBox(width: 10,),
              // SvgPicture.asset(assetPath, width: 24, height: 24, color: isActive ? AppColors.appBarBackgroundColor : AppColors.white,),
            ],
            // children: [
            //   SvgPicture.asset(assetPath, width: 24, height: 24, color: isActive ? AppColors.appBarBackgroundColor : AppColors.white,),
            //   const SizedBox(width: 10,),
            //   Text(title,
            //     style: TextStyle(color: isActive ? AppColors.appBarBackgroundColor : AppColors.white, fontSize: 18),),
            // ],
          ),
        )
    );
  }

}