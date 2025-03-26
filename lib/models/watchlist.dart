class Watchlist {
  final String id;
  final String name;
  final List<String> fundIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Watchlist({
    required this.id,
    required this.name,
    required this.fundIds,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'fundIds': fundIds,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Watchlist.fromJson(Map<String, dynamic> json) => Watchlist(
    id: json['id'],
    name: json['name'],
    fundIds: List<String>.from(json['fundIds']),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  Watchlist copyWith({
    String? id,
    String? name,
    List<String>? fundIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Watchlist(
      id: id ?? this.id,
      name: name ?? this.name,
      fundIds: fundIds ?? this.fundIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 