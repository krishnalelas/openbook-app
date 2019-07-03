import 'package:Buzzing/models/categories_list.dart';
import 'package:Buzzing/models/category.dart';
import 'package:Buzzing/widgets/category_badge.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBCategoriesPicker extends StatefulWidget {
  final List<Category> initialCategories;
  final ValueChanged<List<Category>> onChanged;
  final maxSelections;

  const OBCategoriesPicker(
      {Key key,
      this.initialCategories,
      this.maxSelections,
      @required this.onChanged})
      : super(key: key);

  @override
  OBCategoriesPickerState createState() {
    return OBCategoriesPickerState();
  }
}

class OBCategoriesPickerState extends State<OBCategoriesPicker> {
  UserService _userService;

  bool _needsBootstrap;

  List<Category> _categories;
  List<Category> _pickedCategories;

  @override
  void initState() {
    super.initState();
    _categories = [];
    _pickedCategories = widget.initialCategories == null
        ? []
        : widget.initialCategories.toList();
    _needsBootstrap = true;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      var buzzingProvider = BuzzingProvider.of(context);
      _userService = buzzingProvider.userService;
      _bootstrap();
      _needsBootstrap = false;
    }

    return Wrap(
        alignment: WrapAlignment.start,
        spacing: 10,
        runSpacing: 10,
        children: _categories.map(_buildCategory).toList());
  }

  Widget _buildCategory(Category category) {
    return OBCategoryBadge(
      category: category,
      size: OBCategoryBadgeSize.large,
      isEnabled: _pickedCategories.contains(category),
      onPressed: _onCategoryPressed,
    );
  }

  void _onCategoryPressed(Category pressedCategory) {
    if (_pickedCategories.contains(pressedCategory)) {
      // Remove
      _removeSelectedCategory(pressedCategory);
    } else {
      // Add
      if (widget.maxSelections != null &&
          widget.maxSelections == _pickedCategories.length) return;
      _addSelectedCategory(pressedCategory);
    }

    if (widget.onChanged != null) widget.onChanged(_pickedCategories.toList());
  }

  void _addSelectedCategory(Category category) {
    setState(() {
      _pickedCategories.add(category);
    });
  }

  void _removeSelectedCategory(Category category) {
    setState(() {
      _pickedCategories.remove(category);
    });
  }

  void _setCategories(List<Category> categories) {
    setState(() {
      _categories = categories;
    });
  }

  void _bootstrap() async {
    CategoriesList categoriesList = await _userService.getCategories();
    _setCategories(categoriesList.categories);
  }
}
