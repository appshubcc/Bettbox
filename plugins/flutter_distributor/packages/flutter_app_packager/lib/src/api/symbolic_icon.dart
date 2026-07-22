class SymbolicIcon {
  SymbolicIcon({
    required this.name,
    required this.source,
  });

  factory SymbolicIcon.fromJson(Map<String, dynamic> map) {
    return SymbolicIcon(
      name: map['name'] as String,
      source: map['source'] as String,
    );
  }

  String name;
  String source;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'source': source,
    };
  }

  static List<SymbolicIcon>? fromJsonList(dynamic json) {
    if (json == null) return null;
    return (json as List<dynamic>)
        .map((e) => SymbolicIcon.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
