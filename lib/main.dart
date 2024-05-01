import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'UI/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: 'https://lwioiwxyjemmmjqkwuha.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx3aW9pd3h5amVtbW1qcWt3dWhhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTI4OTE4NzgsImV4cCI6MjAyODQ2Nzg3OH0._f8nivdnCpd7p5OBAHjQX2hgCdO8zLYTmF4q6hityas'
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Defect A/S System',
      theme: ThemeData(),
      home: const LoginPage(),
    )
  );
}



