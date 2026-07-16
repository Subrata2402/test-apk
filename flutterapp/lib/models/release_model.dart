class ReleaseModel {
  final int buildNumber;
  final String version;
  final String releaseNotes;
  final String date;
  final String size;
  final String? appName;
  final String? sha256;
  final String? minSdkVersion;
  final String? targetSdkVersion;
  final List<String> permissions;
  final String? appIcon; // base64
  final String? uploadedByEmail;
  final String? uploadedByName;

  const ReleaseModel({
    required this.buildNumber,
    required this.version,
    required this.releaseNotes,
    required this.date,
    required this.size,
    this.appName,
    this.sha256,
    this.minSdkVersion,
    this.targetSdkVersion,
    this.permissions = const [],
    this.appIcon,
    this.uploadedByEmail,
    this.uploadedByName,
  });

  factory ReleaseModel.fromJson(Map<String, dynamic> json) => ReleaseModel(
    buildNumber: json['buildNumber'] as int,
    version: (json['version'] as String?) ?? '1.0.0',
    releaseNotes: (json['releaseNotes'] as String?) ?? '',
    date: (json['date'] as String?) ?? '',
    size: (json['size'] as String?) ?? 'Unknown',
    appName: json['appName'] as String?,
    sha256: json['sha256'] as String?,
    minSdkVersion: json['minSdkVersion'] as String?,
    targetSdkVersion: json['targetSdkVersion'] as String?,
    permissions: (json['permissions'] as List?)?.map((e) => e.toString()).toList() ?? [],
    appIcon: json['appIcon'] as String?,
    uploadedByEmail: json['uploadedByEmail'] as String?,
    uploadedByName: json['uploadedByName'] as String?,
  );
}
