class CategoryModel {
  final int id;
  final String name;
  final bool isDefault;

  CategoryModel({required this.id, required this.name, this.isDefault = false});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
