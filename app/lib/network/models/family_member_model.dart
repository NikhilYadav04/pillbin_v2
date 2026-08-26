class FamilyMember {
  final String id;
  final String name;
  final String? relation;

  const FamilyMember({
    required this.id,
    required this.name,
    this.relation,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
        id: json["_id"] ?? "",
        name: json["name"] ?? "",
        relation: json["relation"],
      );
}
