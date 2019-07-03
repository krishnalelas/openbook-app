import 'package:Buzzing/provider.dart';
import 'package:Buzzing/widgets/icon.dart';
import 'package:Buzzing/widgets/theming/text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OBDateField extends StatefulWidget {
  final String title;
  final DateTime initialDate;
  final ValueChanged<DateTime> onChanged;
  final DateTime minimumDate;
  final DateTime maximumDate;

  const OBDateField(
      {Key key,
      @required this.title,
      @required this.initialDate,
      this.onChanged,
      @required this.minimumDate,
      @required this.maximumDate})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OBDateFieldState();
  }
}

class OBDateFieldState extends State<OBDateField> {
  DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    var buzzingProvider = BuzzingProvider.of(context);
    var datePickerService = buzzingProvider.datePickerService;

    return MergeSemantics(
      child: ListTile(
        leading: const OBIcon(OBIcons.cake),
        title: OBText(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: OBText(DateFormat.yMMMMd().format(_currentDate)),
        onTap: () {
          datePickerService.pickDate(
              maximumDate: widget.maximumDate,
              minimumDate: widget.minimumDate,
              context: context,
              initialDate: widget.initialDate,
              onDateChanged: (DateTime newDate) {
                setState(() {
                  _currentDate = newDate;
                });

                widget.onChanged(newDate);
              });
        },
      ),
    );
  }
}
