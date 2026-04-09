class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
}
