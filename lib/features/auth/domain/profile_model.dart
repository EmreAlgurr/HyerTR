class ProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String role;
  final String? bio;          // Yeni
  final String? phoneNumber;  // Yeni
  
  ProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    required this.role,
    this.bio,
    this.phoneNumber,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'tasker',
      bio: json['bio'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
      'bio': bio,
      'phone_number': phoneNumber,
    };
  }
}
