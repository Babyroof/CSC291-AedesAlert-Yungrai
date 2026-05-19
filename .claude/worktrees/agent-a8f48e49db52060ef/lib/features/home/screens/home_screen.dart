import 'package:flutter/material.dart';
import '../../../core/widgets/yungrai_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: YungraiAppBar(),
      body: Center(child: Text('Home Screen')),
    );
  }
}
