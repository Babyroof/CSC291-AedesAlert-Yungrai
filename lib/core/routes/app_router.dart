import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/checklist_screen.dart';
import '../../features/home/presentation/screens/report_risk_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/news/presentation/screens/news_list_screen.dart';
import '../../features/news/presentation/screens/news_detail_screen.dart';
import '../../features/news/presentation/screens/news_article_detail_screen.dart';
import '../../features/news/domain/entities/article_entity.dart';
import '../../features/news/domain/entities/news_article_entity.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/ranking/presentation/screens/ranking_screen.dart';
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
const String routeNewsArticle = '/news-article';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellMapKey = GlobalKey<NavigatorState>(debugLabel: 'map');
final _shellDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _shellProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

// Listens to Firebase auth state and notifies GoRouter to re-evaluate redirects.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _authNotifier = _AuthNotifier();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  refreshListenable: _authNotifier,
  redirect: (BuildContext context, GoRouterState state) {
    final user = FirebaseAuth.instance.currentUser;
    final onAuthPage =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';

    if (user == null && !onAuthPage) return '/login';
    if (user != null && onAuthPage) return '/home';
    return null;
  },
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
    GoRoute(
      path: routeNews,
      builder: (context, state) => const NewsListScreen(),
    ),
    GoRoute(
      path: routeNewsArticle,
      builder: (context, state) =>
          NewsArticleDetailScreen(article: state.extra as NewsArticleEntity),
    ),
    GoRoute(
      path: '$routeNews/:id',
      builder: (context, state) => NewsDetailScreen(
        id: state.pathParameters['id']!,
        article: state.extra as ArticleEntity?,
      ),
    ),
    GoRoute(
      path: '/ranking',
      builder: (context, state) => const RankingScreen(),
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
