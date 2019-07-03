import 'package:Buzzing/pages/auth/create_account/blocs/create_account.dart';
import 'package:Buzzing/services/auth_api.dart';
import 'package:Buzzing/services/bottom_sheet.dart';
import 'package:Buzzing/services/categories_api.dart';
import 'package:Buzzing/services/communities_api.dart';
import 'package:Buzzing/services/connections_circles_api.dart';
import 'package:Buzzing/services/connections_api.dart';
import 'package:Buzzing/services/date_picker.dart';
import 'package:Buzzing/services/devices_api.dart';
import 'package:Buzzing/services/dialog.dart';
import 'package:Buzzing/services/documents.dart';
import 'package:Buzzing/services/intercom.dart';
import 'package:Buzzing/services/moderation_api.dart';
import 'package:Buzzing/services/notifications_api.dart';
import 'package:Buzzing/services/push_notifications/push_notifications.dart';
import 'package:Buzzing/services/universal_links/universal_links.dart';
import 'package:Buzzing/services/emoji_picker.dart';
import 'package:Buzzing/services/emojis_api.dart';
import 'package:Buzzing/services/environment_loader.dart';
import 'package:Buzzing/services/follows_api.dart';
import 'package:Buzzing/services/httpie.dart';
import 'package:Buzzing/services/image_picker.dart';
import 'package:Buzzing/services/follows_lists_api.dart';
import 'package:Buzzing/services/localization.dart';
import 'package:Buzzing/services/modal_service.dart';
import 'package:Buzzing/services/navigation_service.dart';
import 'package:Buzzing/services/posts_api.dart';
import 'package:Buzzing/services/storage.dart';
import 'package:Buzzing/services/string_template.dart';
import 'package:Buzzing/services/theme.dart';
import 'package:Buzzing/services/theme_value_parser.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/services/url_launcher.dart';
import 'package:Buzzing/services/user.dart';
import 'package:Buzzing/services/user_invites_api.dart';
import 'package:Buzzing/services/user_preferences.dart';
import 'package:Buzzing/services/utils_service.dart';
import 'package:Buzzing/services/validation.dart';
import 'package:Buzzing/services/waitlist_service.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';

// TODO Waiting for dependency injection support
// https://github.com/flutter/flutter/issues/21980

class BuzzingProvider extends StatefulWidget {
  final Widget child;

  const BuzzingProvider({Key key, @required this.child}) : super(key: key);

  @override
  BuzzingProviderState createState() {
    return BuzzingProviderState();
  }

  static BuzzingProviderState of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_BuzzingProvider)
            as _BuzzingProvider)
        .data;
  }
}

class BuzzingProviderState extends State<BuzzingProvider> {
  UserPreferencesService userPreferencesService = UserPreferencesService();
  CreateAccountBloc createAccountBloc = CreateAccountBloc();
  ValidationService validationService = ValidationService();
  HttpieService httpService = HttpieService();
  AuthApiService authApiService = AuthApiService();
  PostsApiService postsApiService = PostsApiService();
  StorageService storageService = StorageService();
  UserService userService = UserService();
  ModerationApiService moderationApiService = ModerationApiService();
  ToastService toastService = ToastService();
  StringTemplateService stringTemplateService = StringTemplateService();
  EmojisApiService emojisApiService = EmojisApiService();
  ThemeService themeService = ThemeService();
  ImagePickerService imagePickerService = ImagePickerService();
  DatePickerService datePickerService = DatePickerService();
  EmojiPickerService emojiPickerService = EmojiPickerService();
  FollowsApiService followsApiService = FollowsApiService();
  CommunitiesApiService communitiesApiService = CommunitiesApiService();
  CategoriesApiService categoriesApiService = CategoriesApiService();
  NotificationsApiService notificationsApiService = NotificationsApiService();
  DevicesApiService devicesApiService = DevicesApiService();
  ConnectionsApiService connectionsApiService = ConnectionsApiService();
  ConnectionsCirclesApiService connectionsCirclesApiService =
      ConnectionsCirclesApiService();
  FollowsListsApiService followsListsApiService = FollowsListsApiService();
  UserInvitesApiService userInvitesApiService = UserInvitesApiService();
  ThemeValueParserService themeValueParserService = ThemeValueParserService();
  ModalService modalService = ModalService();
  NavigationService navigationService = NavigationService();
  WaitlistApiService waitlistApiService = WaitlistApiService();

  LocalizationService localizationService;
  UniversalLinksService universalLinksService = UniversalLinksService();
  BottomSheetService bottomSheetService = BottomSheetService();
  PushNotificationsService pushNotificationsService =
      PushNotificationsService();
  UrlLauncherService urlLauncherService = UrlLauncherService();
  IntercomService intercomService = IntercomService();
  DialogService dialogService = DialogService();
  UtilsService utilsService = UtilsService();
  DocumentsService documentsService = DocumentsService();

  SentryClient sentryClient;

  @override
  void initState() {
    super.initState();
    initAsyncState();
    imageCache.maximumSize = 200 << 20; // 200MB
    userPreferencesService.setStorageService(storageService);
    connectionsCirclesApiService.setHttpService(httpService);
    httpService.setUtilsService(utilsService);
    connectionsCirclesApiService
        .setStringTemplateService(stringTemplateService);
    communitiesApiService.setHttpieService(httpService);
    communitiesApiService.setStringTemplateService(stringTemplateService);
    followsListsApiService.setHttpService(httpService);
    followsListsApiService.setStringTemplateService(stringTemplateService);
    userInvitesApiService.setHttpService(httpService);
    userInvitesApiService.setStringTemplateService(stringTemplateService);
    connectionsApiService.setHttpService(httpService);
    authApiService.setHttpService(httpService);
    authApiService.setStringTemplateService(stringTemplateService);
    followsApiService.setHttpService(httpService);
    createAccountBloc.setAuthApiService(authApiService);
    createAccountBloc.setUserService(userService);
    userService.setAuthApiService(authApiService);
    userService.setPostsApiService(postsApiService);
    userService.setEmojisApiService(emojisApiService);
    userService.setHttpieService(httpService);
    userService.setStorageService(storageService);
    userService.setUserInvitesApiService(userInvitesApiService);
    userService.setFollowsApiService(followsApiService);
    userService.setFollowsListsApiService(followsListsApiService);
    userService.setConnectionsApiService(connectionsApiService);
    userService.setConnectionsCirclesApiService(connectionsCirclesApiService);
    userService.setCommunitiesApiService(communitiesApiService);
    userService.setCategoriesApiService(categoriesApiService);
    userService.setNotificationsApiService(notificationsApiService);
    userService.setDevicesApiService(devicesApiService);
    userService.setCreateAccountBlocService(createAccountBloc);
    userService.setWaitlistApiService(waitlistApiService);
    waitlistApiService.setHttpService(httpService);
    userService.setModerationApiService(moderationApiService);
    emojisApiService.setHttpService(httpService);
    categoriesApiService.setHttpService(httpService);
    postsApiService.setHttpieService(httpService);
    postsApiService.setStringTemplateService(stringTemplateService);
    notificationsApiService.setHttpService(httpService);
    notificationsApiService.setStringTemplateService(stringTemplateService);
    devicesApiService.setHttpService(httpService);
    devicesApiService.setStringTemplateService(stringTemplateService);
    validationService.setAuthApiService(authApiService);
    validationService.setFollowsListsApiService(followsListsApiService);
    validationService.setCommunitiesApiService(communitiesApiService);
    validationService
        .setConnectionsCirclesApiService(connectionsCirclesApiService);
    themeService.setStorageService(storageService);
    pushNotificationsService.setUserService(userService);
    intercomService.setUserService(userService);
    dialogService.setThemeService(themeService);
    dialogService.setThemeValueParserService(themeValueParserService);
    imagePickerService.setValidationService(validationService);
    documentsService.setHttpService(httpService);
    moderationApiService.setStringTemplateService(stringTemplateService);
    moderationApiService.setHttpieService(httpService);
  }

  void initAsyncState() async {
    Environment environment =
        await EnvironmentLoader(environmentPath: ".env.json").load();
    httpService.setMagicHeader(
        environment.magicHeaderName, environment.magicHeaderValue);
    authApiService.setApiURL(environment.apiUrl);
    postsApiService.setApiURL(environment.apiUrl);
    emojisApiService.setApiURL(environment.apiUrl);
    userInvitesApiService.setApiURL(environment.apiUrl);
    followsApiService.setApiURL(environment.apiUrl);
    moderationApiService.setApiURL(environment.apiUrl);
    connectionsApiService.setApiURL(environment.apiUrl);
    connectionsCirclesApiService.setApiURL(environment.apiUrl);
    followsListsApiService.setApiURL(environment.apiUrl);
    communitiesApiService.setApiURL(environment.apiUrl);
    categoriesApiService.setApiURL(environment.apiUrl);
    notificationsApiService.setApiURL(environment.apiUrl);
    devicesApiService.setApiURL(environment.apiUrl);
    waitlistApiService.setBuzzingSocialApiURL(environment.buzzingSocialApiUrl);
    intercomService.bootstrap(
        iosApiKey: environment.intercomIosKey,
        androidApiKey: environment.intercomAndroidKey,
        appId: environment.intercomAppId);

    sentryClient = SentryClient(dsn: environment.sentryDsn);
  }

  @override
  Widget build(BuildContext context) {
    return new _BuzzingProvider(
      data: this,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    super.dispose();
    universalLinksService.dispose();
    pushNotificationsService.dispose();
  }

  setLocalizationService(LocalizationService newLocalizationService) {
    localizationService = newLocalizationService;
    createAccountBloc.setLocalizationService(localizationService);
    httpService.setLocalizationService(localizationService);
  }

  setValidationService(ValidationService newValidationService) {
    validationService = newValidationService;
  }
}

class _BuzzingProvider extends InheritedWidget {
  final BuzzingProviderState data;

  _BuzzingProvider({Key key, this.data, Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_BuzzingProvider old) {
    return true;
  }
}
