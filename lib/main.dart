import 'package:flutter/material.dart';
import 'viewmodels/home_viewmodel.dart';
import 'views/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Instantiate our HomeViewModel. For this simple app, we can pass it down
    // or instantiate it here directly. If we need global state management later,
    // we can use standard dependency injection or provider.
    final homeViewModel = HomeViewModel();

    return MaterialApp(
      title: 'Retro Game Arcade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFF007F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFF007F),
          secondary: Color(0xFF7F00FF),
          background: Color(0xFF0F2027),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Default clean font
      ),
      home: HomeView(viewModel: homeViewModel),
    );
  }
}
