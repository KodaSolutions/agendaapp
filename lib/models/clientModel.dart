class Client {
  final int id;
  final String name;
  final String email;
  final int number;

  Client({
    required this.id,
    required this.name,
    required this.number,
    required this.email
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      number: _toInt(json['number']),
      email: json['email']?.toString() ?? '',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    } else {
      return 0;
    }
  }
}
