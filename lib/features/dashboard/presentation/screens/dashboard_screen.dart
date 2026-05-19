import 'package:flutter/material.dart';
import '../../../../core/widgets/yungrai_app_bar.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: YungraiAppBar(),
      body: Center(child: Text('Dashboard Screen')),
    );
  }
}
