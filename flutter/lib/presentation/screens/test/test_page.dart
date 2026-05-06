import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackgroundColor,
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light
          ),
          leading: IconButton(
            icon: const Column(
              children: [
                Icon(Icons.menu),
                Text("Menu", style: TextStyle(color: AppColors.white, fontSize: 8), overflow: TextOverflow.ellipsis,)
              ],
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
              // scaffoldKey.currentState!.openDrawer();
            },
          ),
        ),
        body: const Center(
          child: Text("Demo drawer"),
        )
    );
  }
}