import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';

class FcmService {
  FcmService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> initialize(String uid, {String? district}) async {
    // 1. Request permission
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // 2. Get token and save to Firestore
    // TODO: Generate a VAPID key from Firebase Console → Project Settings →
    // Cloud Messaging → Web Push certificates → Generate key pair, then
    // replace the empty string below with the actual key.
    const webVapidKey = ''; // <-- paste your Web Push VAPID key here
    final token = await FirebaseMessaging.instance.getToken(
      vapidKey: (kIsWeb && webVapidKey.isNotEmpty) ? webVapidKey : null,
    );
    if (token != null) await _saveToken(uid, token, district: district);

    // 3. Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh
        .listen((newToken) => _saveToken(uid, newToken, district: district));

    // 4. Foreground message handler
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] foreground message: ${message.notification?.title}');
    });
  }

  Future<void> _saveToken(String uid, String token, {String? district}) async {
    final Map<String, dynamic> data = {'fcmToken': token};
    if (district != null && district.isNotEmpty) data['district'] = district;
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }
}