import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import 'UI/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final statusCamera = await Permission.camera.status;
  if( statusCamera.isDenied )  {
    await Permission.camera.request();
  }

  final statusStorage = await Permission.storage.status;
  if( statusStorage.isDenied )  {
    await Permission.storage.request();
  }

  final statusPhotos = await Permission.photos.status;
  if( statusPhotos.isDenied )  {
    await Permission.photos.request();
  }

  await Supabase.initialize(
      url: 'https://drmfczqtnhslrpejkqst.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRybWZjenF0bmhzbHJwZWprcXN0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjYwOTk1OTYsImV4cCI6MjA0MTY3NTU5Nn0.q1oO5l50dNxF-I9SgMfl3GtsSfT8pV3pMQQPyRhPYI0'
  );

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Defect A/S System',
    theme: ThemeData(),
    home: const LoginPage(),
    builder: (context, child)  {
      final MediaQueryData data = MediaQuery.of(context);
      return MediaQuery(
        child: child!,
        data: data.copyWith(textScaleFactor: 1.0),
      );
    },
  ));
}



