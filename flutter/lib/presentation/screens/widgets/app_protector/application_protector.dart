import 'package:flutter/material.dart';

class ApplicationProtectorWidget extends StatefulWidget {
  const ApplicationProtectorWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  State<ApplicationProtectorWidget> createState() =>
      _ApplicationProtectorWidgetState();
}

class _ApplicationProtectorWidgetState extends State<ApplicationProtectorWidget>
    with WidgetsBindingObserver {
  bool isProtectContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      // isProtectContent = state == AppLifecycleState.inactive ||
      //     state == AppLifecycleState.paused;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (isProtectContent) {
      return Scaffold(
        body: Stack(
          children: [
            widget.child ?? Container(),
            Container(
              height: size.height,
              width: size.width,
              color: Colors.white,
              child: _buildProtectView(),
            ),
          ],
        ),
      );
    }

    return widget.child ?? Container();
  }

  Widget _buildProtectView() {
    return const Center(
        child: Text(
      'Abplivestock',
      style: TextStyle(
          fontSize: 34, fontWeight: FontWeight.w700, color: Colors.black),
    ));
  }
}
