import 'package:app_itr/etc/ThemeCTRM.dart';
import 'package:app_itr/stores/login_data_store.dart';
import 'package:app_itr/ui/TitleHome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {

  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarBrightness: Brightness.light) // Or Brightness.dark
  );

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      Provider<LoginDataStore>(create: (context) => LoginDataStore()),
    ],
    child: MaterialApp(
      title: "APP CTRM",
      home: TitleHome(),
      debugShowCheckedModeBanner: false,
      theme: ThemeCTRM(),
      themeMode: ThemeMode.light,
    ),
  ));
}
