import 'package:Buzzing/provider.dart';
import 'package:Buzzing/services/toast.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBClearApplicationCacheTile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBClearApplicationCacheTileState();
  }
}

class OBClearApplicationCacheTileState
    extends State<OBClearApplicationCacheTile> {
  bool _inProgress;
  ToastService _toastService;

  @override
  initState() {
    super.initState();
    _inProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    return OBLoadingTile(
      leading: OBIcon(OBIcons.clear),
      title: OBText('Clear cache'),
      subtitle: OBSecondaryText('Clear cached posts, accounts, images & more.'),
      isLoading: _inProgress,
      onTap: _clearApplicationCache,
    );
  }

  Future _clearApplicationCache() async {
    _setInProgress(true);

    BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);
    try {
      await buzzingProvider.userService.clearCache();
      buzzingProvider.toastService
          .success(message: 'Cleared cache successfully', context: context);
    } catch (error) {
      buzzingProvider.toastService
          .error(message: 'Could not clear cache', context: context);
      rethrow;
    } finally {
      _setInProgress(false);
    }
  }

  void _setInProgress(bool inProgress) {
    setState(() {
      this._inProgress = inProgress;
    });
  }
}
