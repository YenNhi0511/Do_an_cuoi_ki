class GroupModel {
  final String id;
  final String name;
  final List<String> members;

  GroupModel({
    required this.id,
    required this.name,
    required this.members,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      members: List<String>.from(json['members'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'members': members,
    };
  }
}
