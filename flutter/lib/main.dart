import 'package:flutter/material.dart';
import 'package:flutter_demo/di/service_locator.dart';
import 'package:flutter_demo/presentation/helper/loading_helper.dart';

import 'presentation/myapp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MyApp());
  LoadingHelper.configLoading();
}
