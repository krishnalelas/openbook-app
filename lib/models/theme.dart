import 'package:Buzzing/models/updatable_model.dart';
import 'package:dcache/dcache.dart';

class OBTheme extends UpdatableModel<OBTheme> {
  int id;

  String name;

  String primaryTextColor;
  String secondaryTextColor;

  String primaryColor;
  String primaryAccentColor;

  String successColor;
  String successColorAccent;

  String dangerColor;
  String dangerColorAccent;

  String themePreview;

  static final factory = OBThemeFactory();

  factory OBTheme.fromJson(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  OBTheme(
      {this.id,
      this.name,
      this.primaryColor,
      this.primaryAccentColor,
      this.dangerColor,
      this.dangerColorAccent,
      this.successColor,
      this.successColorAccent,
      this.themePreview,
      this.primaryTextColor,
      this.secondaryTextColor})
      : super();

  @override
  void updateFromJson(Map json) {
    primaryTextColor = json['primary_text_color'];
    secondaryTextColor = json['secondary_text_color'];
    primaryColor = json['primary_color'];
    primaryAccentColor = json['accent_color'];
    successColor = json['primary_button_color'];
    successColorAccent = json['primary_button_text_color'];
    dangerColor = json['danger_button_color'];
    dangerColorAccent = json['danger_button_text_color'];
  }
}

class OBThemeFactory extends UpdatableModelFactory<OBTheme> {
  @override
  SimpleCache<int, OBTheme> cache = LruCache(storage: UpdatableModelSimpleStorage(size: 10));

  @override
  OBTheme makeFromJson(Map json) {
    return OBTheme(
        primaryTextColor: json['primary_text_color'],
        secondaryTextColor: json['secondary_text_color'],
        primaryColor: json['primary_color'],
        primaryAccentColor: json['accent_color'],
        successColor: json['primary_button_color'],
        successColorAccent: json['primary_button_text_color'],
        dangerColor: json['danger_button_color'],
        dangerColorAccent: json['danger_button_text_color']);
  }
}
