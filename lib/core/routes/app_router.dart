import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/checklist_screen.dart';
import '../../features/home/screens/report_risk_screen.dart';
import '../../features/map/screens/map_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/news/screens/news_list_screen.dart';
import '../../features/news/screens/news_detail_screen.dart';
import '../../features/notification/screens/notification_screen.dart';
import '../widgets/app_bottom_nav.dart';

// Route path constants
const String routeLogin = '/login';
const String routeRegister = '/register';
const String routeHome = '/home';
const String routeMap = '/map';
const String routeDashboard = '/dashboard';
const String routeProfile = '/profile';
const String routeNotification = '/notification';
const String routeNews = '/news';
const String routeChecklist = '/checklist';
const String routeReportRisk = '/report-risk';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellMapKey = GlobalKey<NavigatorState>(debugLabel: 'map');
final _shellDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _shellProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: routeLogin,
  routes: [
    GoRoute(path: routeLogin, builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: routeRegister,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: routeNotification,
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: routeChecklist,
      builder: (context, state) => const ChecklistScreen(),
    ),
    GoRoute(
      path: routeReportRisk,
      builder: (context, state) => const ReportRiskScreen(),
    ),
    GoRoute(path: routeNews, builder: (context, state) => const NewsListScreen()),
    GoRoute(
      path: '$routeNews/:id',
      builder: (context, state) =>
          NewsDetailScreen(id: state.pathParameters['id']!),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellHomeKey,
          routes: [
            GoRoute(
              path: routeHome,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellMapKey,
          routes: [
            GoRoute(
              path: routeMap,
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellDashboardKey,
          routes: [
            GoRoute(
              path: routeDashboard,
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellProfileKey,
          routes: [
            GoRoute(
              path: routeProfile,
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  const _ScaffoldWithNavBar({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
