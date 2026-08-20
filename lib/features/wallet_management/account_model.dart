import 'dart:convert';

class AccountModel {
  final String address;
  final int index;
  final String alias;
  final DateTime createdAt;

  AccountModel({required this.address, required this.index, required this.alias, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'address': address,
        'index': index,
        'alias': alias,
        'createdAt': createdAt.toIso8601String(),
      };

  static AccountModel fromJson(Map<String, dynamic> j) => AccountModel(
        address: j['address'] as String,
        index: j['index'] as int,
        alias: j['alias'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );

  @override
  String toString() => jsonEncode(toJson());
}
