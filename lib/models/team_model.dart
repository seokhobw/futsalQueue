class Member {
  final String name;
  final String position;

  Member({required this.name, required this.position});

  factory Member.fromJson(Map<String, dynamic> json) =>
      Member(name: json['name'], position: json['position']);

  Map<String, dynamic> toJson() => {'name': name, 'position': position};
}

class TeamModel {
  final String id;
  final String name;
  final List<Member> members;
  final String? logoUrl;
  final String? region;

  TeamModel({
    required this.id,
    required this.name,
    required this.members,
    this.logoUrl,
    this.region,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) => TeamModel(
        id: json['id'],
        name: json['name'],
        logoUrl: json['logoUrl'],
        region: json['region'],
        members: (json['members'] as List)
            .map((m) => Member.fromJson(Map<String, dynamic>.from(m)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'logoUrl': logoUrl,
        'region': region,
        'members': members.map((m) => m.toJson()).toList(),
      };
}