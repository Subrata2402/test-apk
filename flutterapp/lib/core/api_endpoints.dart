class ApiEndpoints {
  static const String authGoogle = '/auth/google';
  static const String usersMe = '/users/me';
  static const String fcmToken = '/users/fcm-token';
  static const String apps = '/apps';
  static const String invitations = '/apps/invitations';
  static const String logout = '/auth/logout';

  static String acceptInvitation(String appId) => '/apps/$appId/invitations/accept';
  static String rejectInvitation(String appId) => '/apps/$appId/invitations/reject';
  static String downloadRelease(String appId, int buildNumber) => '/apps/$appId/releases/$buildNumber/download';
  static String appReleases(String appId) => '/apps/$appId/releases';
  static String appMembers(String appId) => '/apps/$appId/members';
}
