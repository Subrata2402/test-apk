import 'dart:developer' as developer;
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';
import 'storage_service.dart';
import '../models/user_model.dart';
import '../notification_manager.dart';

import 'constants.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _googleSignIn = GoogleSignIn(serverClientId: kGoogleClientId, scopes: ['email', 'profile']);

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) return null;

      // Exchange idToken for our JWT
      final response = await ApiService.instance.loginWithGoogle(idToken);

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        final token = body['token'] as String;
        await StorageService.instance.saveToken(token);
        _currentUser = UserModel.fromJson(body['data']['user'] as Map<String, dynamic>);
        // Send FCM token to server
        await NotificationManager.sendTokenToServer();
        return _currentUser;
      }
      return null;
    } catch (e) {
      developer.log('Google Sign-In Error', error: e);
      return null;
    }
  }

  Future<UserModel?> tryAutoLogin() async {
    final token = await StorageService.instance.getToken();
    if (token == null) return null;

    try {
      final response = await ApiService.instance.getUserProfile();
      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        _currentUser = UserModel.fromJson(body['data']['user'] as Map<String, dynamic>);
        // Send FCM token to server
        await NotificationManager.sendTokenToServer();
        return _currentUser;
      }
    } catch (_) {}
    // Token invalid/expired – clear it
    await StorageService.instance.deleteToken();
    return null;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await StorageService.instance.deleteToken();
    _currentUser = null;
  }
}
