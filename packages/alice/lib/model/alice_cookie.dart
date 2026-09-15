class AliceCookie {
  final String name;
  final String value;

  AliceCookie(this.name, this.value);

  Map<String, dynamic> toJson() => {'name': name, 'value': value};

  @override
  String toString() => '$name=$value';
}
