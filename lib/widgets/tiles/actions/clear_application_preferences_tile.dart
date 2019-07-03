import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/secondary_text.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:Buzzing/widgets/tiles/loading_tile.dart';
import 'package:flutter/material.dart';

class OBClearApplicationPreferencesTile extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return OBClearApplicationPreferencesTileState();
  }
}

class OBClearApplicationPreferencesTileState
    extends State<OBClearApplicationPreferencesTile> {
  bool _inProgress;

  @override
  initState() {
    super.initState();
    _inProgress = false;
  }

  @override
  Widget build(BuildContext context) {
    return OBLoadingTile(
      leading: OBIcon(OBIcons.clear),
      title: OBText('Clear preferences'),
      subtitle: OBSecondaryText(
          'Clear the application preferences. Currently this is only the preferred order of comments.'),
      isLoading: _inProgress,
      onTap: _clearApplicationPreferences,
    );
  }

  Future _clearApplicationPreferences() async {
    BuzzingProviderState buzzingProvider = BuzzingProvider.of(context);
    try {
      await buzzingProvider.userPreferencesService.clear();
      buzzingProvider.toastService.success(
          message: 'Cleared preferences successfully', context: context);
    } catch (error) {
      buzzingProvider.toastService
          .error(message: 'Could not clear preferences', context: context);
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
