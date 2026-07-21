import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_endpoints.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final ApiClient _client = ApiClient.instance;

  Future<Response> loginWithGoogle(String idToken) {
    return _client.post(ApiEndpoints.authGoogle, {'idToken': idToken});
  }

  Future<Response> getUserProfile() {
    return _client.get(ApiEndpoints.usersMe);
  }

  Future<Response> sendFcmToken(String token) {
    return _client.post(ApiEndpoints.fcmToken, {'token': token});
  }

  Future<Response> getApps() {
    return _client.get(ApiEndpoints.apps);
  }

  Future<Response> getAppReleases(String appId) {
    return _client.get(ApiEndpoints.appReleases(appId));
  }

  Future<Response> getAppMembers(String appId) {
    return _client.get(ApiEndpoints.appMembers(appId));
  }

  Future<Response> getInvitations() {
    return _client.get(ApiEndpoints.invitations);
  }

  Future<Response> logout(String? fcmToken) {
    return _client.post(
      ApiEndpoints.logout,
      fcmToken != null ? {'fcmToken': fcmToken} : {},
    );
  }

  Future<Response> acceptInvitation(String appId) {
    return _client.post(ApiEndpoints.acceptInvitation(appId), {});
  }

  Future<Response> rejectInvitation(String appId) {
    return _client.post(ApiEndpoints.rejectInvitation(appId), {});
  }

  Future<Response> downloadRelease(String appId, int buildNumber, String savePath, ProgressCallback onReceiveProgress) {
    return _client.dio.download(
      ApiEndpoints.downloadRelease(appId, buildNumber),
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
