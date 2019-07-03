import 'package:Buzzing/models/updatable_model.dart';
import 'package:Buzzing/models/user.dart';
import 'package:dcache/dcache.dart';

class Category extends UpdatableModel<Category> {
  final int id;
  final User creator;
  String name;
  String title;
  String description;
  String avatar;
  String color;

  Category({
    this.id,
    this.creator,
    this.avatar,
    this.color,
    this.title,
    this.description,
    this.name,
  });

  static final factory = CategoryFactory();

  factory Category.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }

    if (json.containsKey('color')) {
      color = json['color'];
    }

    if (json.containsKey('title')) {
      title = json['title'];
    }

    if (json.containsKey('description')) {
      description = json['description'];
    }

    if (json.containsKey('avatar')) {
      avatar = json['avatar'];
    }
  }
}

class CategoryFactory extends UpdatableModelFactory<Category> {
  @override
  SimpleCache<int, Category> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  Category makeFromJson(Map json) {
    return Category(
      id: json['id'],
      name: json['name'],
      title: json['title'],
      description: json['description'],
      avatar: json['avatar'],
      color: json['color'],
      creator: parseUser(json['creator']),
    );
  }

  User parseUser(Map userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }
}
