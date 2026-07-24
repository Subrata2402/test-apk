import 'release_model.dart';

class MemberModel {
  final String email;
  final String role;
  final String status;
  final String name;

  const MemberModel({required this.email, required this.role, required this.status, required this.name});

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
    email: json['email'] as String? ?? '',
    role: json['role'] as String? ?? '',
    status: json['status'] as String? ?? '',
    name: json['name'] as String? ?? '',
  );
}

class AppModel {
  final String id;
  final String name;
  final String packageName;
  final String description;
  final List<ReleaseModel> releases;
  final List<MemberModel> members;
  final String? memberRole;
  final String? icon;

  const AppModel({
    required this.id,
    required this.name,
    required this.packageName,
    required this.description,
    required this.releases,
    required this.members,
    this.memberRole,
    this.icon,
  });

  factory AppModel.fromJson(Map<String, dynamic> json) {
    final membersList = json['members'] as List? ?? [];
    final releasesList = json['releases'] as List? ?? [];

    return AppModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      packageName: json['packageName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      releases: releasesList.map((r) => ReleaseModel.fromJson(r as Map<String, dynamic>)).toList(),
      members: membersList.map((m) => MemberModel.fromJson(m as Map<String, dynamic>)).toList(),
      memberRole: json['memberRole'] as String?,
      icon: json['icon'] as String?,
    );
  }

  ReleaseModel? get latestRelease => releases.isNotEmpty ? releases.first : null;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
