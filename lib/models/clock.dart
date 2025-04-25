
class Clock {
  final int id;
  final String name;

  const Clock({required this.id, required this.name});

  Map<String, Object?> toMap() => { 'id': id, 'name': name };

  @override
  String toString() => 'Clock{id: $id, name: $name}';

  Future<void> insertClock(Clock clock) async {}
}