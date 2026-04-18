import 'package:flutter/material.dart';

import '../features/toll_calculator/domain/toll_calculator.dart';
import '../features/toll_calculator/presentation/home_screen.dart';

class HighwayApp extends StatelessWidget {
  const HighwayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Pretendard', useMaterial3: true),
      home: HomeScreen(calculator: const TollCalculator()),
    );
  }
}
