import 'dart:io';

import 'package:Buzzing/models/category.dart';
import 'package:Buzzing/models/community.dart';
import 'package:Buzzing/services/bottom_sheet.dart';
import 'package:Buzzing/services/image_picker.dart';
import 'package:Buzzing/services/theme_value_parser.dart';
import 'package:Buzzing/widgets/avatars/avatar.dart';
import 'package:Buzzing/widgets/avatars/letter_avatar.dart';
import 'package:Buzzing/widgets/cover.dart';
import 'package:Buzzing/widgets/fields/categories_field.dart';
import 'package:Buzzing/widgets/fields/color_field.dart';
import 'package:Buzzing/widgets/fields/community_type_field.dart';
import 'package:Buzzing/widgets/fields/toggle_field.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/nav_bars/colored_nav_bar.dart';
import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/services/validation.dart';
import 'package:Buzzing/widgets/buttons/button.dart';
import 'package:Buzzing/widgets/fields/text_form_field.dart';
import 'package:Buzzing/widgets/progress_indicator.dart';
import 'package:Buzzing/widgets/theming/primary_color_container.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pigment/pigment.dart';

class OBSaveCommunityModal extends StatefulWidget {
  final Community community;

  const OBSaveCommunityModal({this.community});

  @override
  OBSaveCommunityModalState createState() {
    return OBSaveCommunityModalState();
  }
}

class OBSaveCommunityModalState extends State<OBSaveCommunityModal> {
  UserService _userService;
  ToastService _toastService;
  ValidationService _validationService;
  ImagePickerService _imagePickerService;
  ThemeValueParserService _themeValueParserService;

  bool _requestInProgress;
  bool _formWasSubmitted;
  bool _formValid;
  bool _isEditingExistingCommunity;
  String _takenName;

  GlobalKey<FormState> _formKey;

  TextEditingController _nameController;
  TextEditingController _titleController;
  TextEditingController _descriptionController;
  TextEditingController _userAdjectiveController;
  TextEditingController _usersAdjectiveController;
  TextEditingController _rulesController;
  OBCategoriesFieldController _categoriesFieldController;

  String _color;
  CommunityType _type;
  String _avatarUrl;
  String _coverUrl;
  File _avatarFile;
  File _coverFile;
  bool _invitesEnabled;

  List<Category> _categories;

  @override
  void initState() {
    super.initState();
    _formValid = true;
    _requestInProgress = false;
    _formWasSubmitted = false;
    _nameController = TextEditingController();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _userAdjectiveController = TextEditingController();
    _usersAdjectiveController = TextEditingController();
    _rulesController = TextEditingController();
    _categoriesFieldController = OBCategoriesFieldController();
    _type = CommunityType.public;
    _invitesEnabled = true;
    _categories = [];

    _formKey = GlobalKey<FormState>();
    _isEditingExistingCommunity = widget.community != null;

    if (_isEditingExistingCommunity) {
      _nameController.text = widget.community.name;
      _titleController.text = widget.community.title;
      _descriptionController.text = widget.community.description;
      _userAdjectiveController.text = widget.community.userAdjective;
      _usersAdjectiveController.text = widget.community.usersAdjective;
      _rulesController.text = widget.community.rules;
      _color = widget.community.color;
      _categories = widget.community.categories.categories.toList();
      _type = widget.community.type;
      _avatarUrl = widget.community.avatar;
      _coverUrl = widget.community.cover;
      _invitesEnabled = widget.community.invitesEnabled;
    }

    _nameController.addListener(_updateFormValid);
    _titleController.addListener(_updateFormValid);
    _descriptionController.addListener(_updateFormValid);
    _userAdjectiveController.addListener(_updateFormValid);
    _usersAdjectiveController.addListener(_updateFormValid);
    _rulesController.addListener(_updateFormValid);
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    _userService = buzzingProvider.userService;
    _toastService = buzzingProvider.toastService;
    _validationService = buzzingProvider.validationService;
    _imagePickerService = buzzingProvider.imagePickerService;
    _themeValueParserService = buzzingProvider.themeValueParserService;
    var themeService = buzzingProvider.themeService;

    _color = _color ?? themeService.generateRandomHexColor();

    return CupertinoPageScaffold(
        navigationBar: _buildNavigationBar(),
        child: OBPrimaryColorContainer(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      overflow: Overflow.visible,
                      children: <Widget>[
                        _buildCover(),
                        Positioned(
                          left: 20,
                          child: Column(
                            children: <Widget>[
                              const SizedBox(
                                height: (OBCover.normalSizeHeight) -
                                    (OBAvatar.AVATAR_SIZE_LARGE / 2),
                              ),
                              _buildAvatar()
                            ],
                          ),
                        ),
                        const SizedBox(
                            height: OBCover.normalSizeHeight +
                                OBAvatar.AVATAR_SIZE_LARGE / 2)
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            left: 20.0, right: 20.0, bottom: 40),
                        child: Column(
                          children: <Widget>[
                            OBTextFormField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                size: OBTextFormFieldSize.medium,
                                controller: _titleController,
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  hintText: 'e.g. Travel, Photography, Gaming.',
                                  prefixIcon: const OBIcon(OBIcons.communities),
                                ),
                                validator: (String communityTitle) {
                                  return _validationService
                                      .validateCommunityTitle(communityTitle);
                                }),
                            OBTextFormField(
                                textCapitalization: TextCapitalization.none,
                                size: OBTextFormFieldSize.medium,
                                controller: _nameController,
                                autocorrect: false,
                                decoration: InputDecoration(
                                    prefixIcon: const OBIcon(OBIcons.shortText),
                                    labelText: 'Name',
                                    prefixText: '/c/',
                                    hintText:
                                        ' e.g. travel, photography, gaming.'),
                                validator: (String communityName) {
                                  if (_takenName != null &&
                                      _takenName == communityName) {
                                    return 'Community name "$_takenName" is taken';
                                  }

                                  return _validationService
                                      .validateCommunityName(communityName);
                                }),
                            OBColorField(
                              initialColor: _color,
                              onNewColor: _onNewColor,
                              labelText: 'Color',
                              hintText: '(Tap to change)',
                            ),
                            OBCommunityTypeField(
                              value: _type,
                              title: 'Type',
                              hintText: '(Tap to change)',
                              onChanged: (CommunityType type) {
                                setState(() {
                                  _type = type;
                                });
                              },
                            ),
                            _type == CommunityType.private
                                ? OBToggleField(
                                    value: _invitesEnabled,
                                    title: 'Member Invites',
                                    subtitle: OBText(
                                        'Members can invite people to the community'),
                                    onChanged: (bool value) {
                                      setState(() {
                                        _invitesEnabled = value;
                                      });
                                    },
                                    onTap: () {
                                      setState(() {
                                        _invitesEnabled = !_invitesEnabled;
                                      });
                                    },
                                  )
                                : const SizedBox(),
                            OBCategoriesField(
                              title: 'Category',
                              min: 1,
                              max: 3,
                              controller: _categoriesFieldController,
                              displayErrors: _formWasSubmitted,
                              onChanged: _onCategoriesChanged,
                              initialCategories: _categories,
                            ),
                            OBTextFormField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                size: OBTextFormFieldSize.medium,
                                controller: _descriptionController,
                                maxLines: 3,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                    prefixIcon: const OBIcon(
                                        OBIcons.communityDescription),
                                    labelText: 'Description · Optional',
                                    hintText: 'What is your community about?'),
                                validator: (String communityDescription) {
                                  return _validationService
                                      .validateCommunityDescription(
                                          communityDescription);
                                }),
                            OBTextFormField(
                              textCapitalization: TextCapitalization.sentences,
                              size: OBTextFormFieldSize.medium,
                              controller: _rulesController,
                              decoration: InputDecoration(
                                  prefixIcon:
                                      const OBIcon(OBIcons.communityRules),
                                  labelText: 'Rules · Optional',
                                  hintText:
                                      'Is there something you would like your users to know?'),
                              validator: (String communityRules) {
                                return _validationService
                                    .validateCommunityRules(communityRules);
                              },
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              maxLines: 3,
                            ),
                            OBTextFormField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                size: OBTextFormFieldSize.medium,
                                controller: _userAdjectiveController,
                                decoration: InputDecoration(
                                    prefixIcon:
                                        const OBIcon(OBIcons.communityMember),
                                    labelText: 'Member adjective · Optional',
                                    hintText:
                                        'e.g. traveler, photographer, gamer.'),
                                validator: (String communityUserAdjective) {
                                  return _validationService
                                      .validateCommunityUserAdjective(
                                          communityUserAdjective);
                                }),
                            OBTextFormField(
                                textCapitalization:
                                    TextCapitalization.sentences,
                                size: OBTextFormFieldSize.medium,
                                controller: _usersAdjectiveController,
                                decoration: InputDecoration(
                                    prefixIcon:
                                        const OBIcon(OBIcons.communityMembers),
                                    labelText: 'Members adjective · Optional',
                                    hintText:
                                        'e.g. travelers, photographers, gamers.'),
                                validator: (String communityUsersAdjective) {
                                  return _validationService
                                      .validateCommunityUserAdjective(
                                          communityUsersAdjective);
                                }),
                          ],
                        )),
                  ],
                )),
          ),
        ));
  }

  Widget _buildNavigationBar() {
    Color color = _themeValueParserService.parseColor(_color);
    bool isDarkColor = _themeValueParserService.isDarkColor(color);
    Color actionsColor = isDarkColor ? Colors.white : Colors.black;

    return OBColoredNavBar(
        color: color,
        leading: GestureDetector(
          child: OBIcon(
            OBIcons.close,
            color: actionsColor,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        title:
            _isEditingExistingCommunity ? 'Edit community' : 'Create community',
        trailing: _requestInProgress
            ? OBProgressIndicator(color: actionsColor)
            : OBButton(
                isDisabled: !_formValid,
                isLoading: _requestInProgress,
                size: OBButtonSize.small,
                onPressed: _submitForm,
                child: Text(_isEditingExistingCommunity ? 'Save' : 'Create'),
              ));
  }

  Widget _buildAvatar() {
    bool hasAvatarFile = _avatarFile != null;
    bool hasAvatarUrl = _avatarUrl != null;

    bool hasAvatar = hasAvatarFile || hasAvatarUrl;

    Function _onPressed = hasAvatar ? _clearAvatar : _pickNewAvatar;

    Widget icon = Icon(
      hasAvatar ? Icons.clear : Icons.edit,
      size: 15,
    );

    Widget avatar;

    if (hasAvatar) {
      avatar = OBAvatar(
        borderWidth: 3,
        avatarUrl: _avatarUrl,
        avatarFile: _avatarFile,
        size: OBAvatarSize.large,
      );
    } else {
      avatar = OBLetterAvatar(
          size: OBAvatarSize.large,
          color: Pigment.fromString(_color),
          letter: _nameController.text.isEmpty ? 'C' : _nameController.text[0]);
    }

    return GestureDetector(
        onTap: _onPressed,
        child: Stack(
          children: <Widget>[
            avatar,
            Positioned(
              bottom: 10,
              right: 10,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 30, maxHeight: 30),
                child: FloatingActionButton(
                  heroTag: Key('editCommunityAvatar'),
                  backgroundColor: Colors.white,
                  child: icon,
                  onPressed: _onPressed,
                ),
              ),
            ),
          ],
        ));
  }

  void _pickNewAvatar() async {
    File newAvatar =
        await _imagePickerService.pickImage(imageType: OBImageType.avatar);
    if (newAvatar != null) _setAvatarFile(newAvatar);
  }

  Widget _buildCover() {
    bool hasCoverFile = _coverFile != null;
    bool hasCoverUrl = _coverUrl != null;
    bool hasCover = hasCoverFile || hasCoverUrl;

    Function _onPressed = hasCover ? _clearCover : _pickNewCover;

    Widget icon = Icon(
      hasCover ? Icons.clear : Icons.edit,
      size: 15,
    );

    return GestureDetector(
      onTap: _onPressed,
      child: Stack(
        children: <Widget>[
          OBCover(
            coverUrl: _coverUrl,
            coverFile: _coverFile,
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
              child: FloatingActionButton(
                heroTag: Key('editCommunityCover'),
                backgroundColor: Colors.white,
                child: icon,
                onPressed: _onPressed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickNewCover() async {
    File newCover =
        await _imagePickerService.pickImage(imageType: OBImageType.cover);
    if (newCover != null) _setCoverFile(newCover);
  }

  void _onCategoriesChanged(List<Category> categories) {
    _setCategories(categories);
    // TODO Couldnt find a way to make it work without doing this
    // Perhaps move the entire state of the CategoriesField into here
    _updateFormValid();
  }

  void _clearAvatar() {
    _avatarUrl = null;
    _clearAvatarFile();
  }

  void _clearAvatarFile() {
    _setAvatarFile(null);
  }

  void _setAvatarFile(File avatarFile) {
    setState(() {
      _avatarFile = avatarFile;
    });
  }

  void _clearCover() {
    _coverUrl = null;
    _clearCoverFile();
  }

  void _clearCoverFile() {
    _setCoverFile(null);
  }

  void _setCoverFile(File coverFile) {
    setState(() {
      _coverFile = coverFile;
    });
  }

  bool _validateForm() {
    return _formKey.currentState.validate();
  }

  bool _updateFormValid() {
    if (!_formWasSubmitted) return true;
    var formValid = _validateForm() && _categoriesFieldController.isValid();
    _setFormValid(formValid);
    return formValid;
  }

  void _submitForm() async {
    _formWasSubmitted = true;

    var formIsValid = _updateFormValid();

    if (!formIsValid) return;

    _setRequestInProgress(true);
    try {
      var communityName = _nameController.text;
      bool communityNameTaken = await _isNameTaken(communityName);

      if (communityNameTaken) {
        _setTakenName(communityName);
        _validateForm();
        return;
      }

      Community community = await (_isEditingExistingCommunity
          ? _updateCommunity()
          : _createCommunity());

      Navigator.of(context).pop(community);
    } catch (error) {
      _onError(error);
    } finally {
      _setRequestInProgress(false);
    }
  }

  void _onError(error) async {
    if (error is HttpieConnectionRefusedError) {
      _toastService.error(
          message: error.toHumanReadableMessage(), context: context);
    } else if (error is HttpieRequestError) {
      String errorMessage = await error.toHumanReadableMessage();
      _toastService.error(message: errorMessage, context: context);
    } else {
      _toastService.error(message: 'Unknown error', context: context);
      throw error;
    }
  }

  Future<Community> _updateCommunity() async {
    await _updateCommunityAvatar();
    await _updateCommunityCover();

    return _userService.updateCommunity(widget.community,
        name: _nameController.text != widget.community.name
            ? _nameController.text
            : null,
        title: _titleController.text,
        description: _descriptionController.text,
        rules: _rulesController.text,
        userAdjective: _userAdjectiveController.text,
        usersAdjective: _usersAdjectiveController.text,
        categories: _categories,
        type: _type,
        invitesEnabled: _invitesEnabled,
        color: _color);
  }

  Future<void> _updateCommunityCover() {
    bool hasCoverFile = _coverFile != null;
    bool hasCoverUrl = _coverUrl != null;
    bool hasCover = hasCoverFile || hasCoverUrl;

    Future<void> updateFuture;

    if (!hasCover) {
      if (widget.community.cover != null) {
        // Remove cover!
        updateFuture = _userService.deleteCoverForCommunity(widget.community);
      }
    } else if (hasCoverFile) {
      // New cover
      updateFuture = _userService.updateCoverForCommunity(widget.community,
          cover: _coverFile);
    } else {
      updateFuture = Future.value();
    }

    return updateFuture;
  }

  Future<void> _updateCommunityAvatar() {
    bool hasAvatarFile = _avatarFile != null;
    bool hasAvatarUrl = _avatarUrl != null;
    bool hasAvatar = hasAvatarFile || hasAvatarUrl;

    Future<void> updateFuture;

    if (!hasAvatar) {
      if (widget.community.avatar != null) {
        // Remove avatar!
        updateFuture = _userService.deleteAvatarForCommunity(widget.community);
      }
    } else if (hasAvatarFile) {
      // New avatar
      updateFuture = _userService.updateAvatarForCommunity(widget.community,
          avatar: _avatarFile);
    } else {
      updateFuture = Future.value();
    }

    return updateFuture;
  }

  Future<Community> _createCommunity() {
    return _userService.createCommunity(
        type: _type,
        name: _nameController.text,
        title: _titleController.text,
        description: _descriptionController.text,
        rules: _rulesController.text,
        userAdjective: _userAdjectiveController.text,
        usersAdjective: _usersAdjectiveController.text,
        categories: _categories,
        invitesEnabled: _invitesEnabled,
        color: _color,
        avatar: _avatarFile,
        cover: _coverFile);
  }

  Future<bool> _isNameTaken(String communityName) async {
    if (_isEditingExistingCommunity &&
        widget.community.name == _nameController.text) {
      return false;
    }
    return _validationService.isCommunityNameTaken(communityName);
  }

  void _onNewColor(String newColor) {
    _setColor(newColor);
  }

  void _setColor(String color) {
    setState(() {
      _color = color;
    });
  }

  void _setCategories(List<Category> categories) {
    setState(() {
      _categories = categories;
    });
  }

  void _setRequestInProgress(bool requestInProgress) {
    setState(() {
      _requestInProgress = requestInProgress;
    });
  }

  void _setFormValid(bool formValid) {
    setState(() {
      _formValid = formValid;
    });
  }

  void _setTakenName(String takenCommunityName) {
    setState(() {
      _takenName = takenCommunityName;
    });
  }
}
