import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OBSlideRightRoute<T> extends PageRouteBuilder<T> {
  final Widget widget;
  final Key key;

  OBSlideRightRoute({this.widget, this.key})
      : super(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 200),
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return Dismissible(
                  background: const DecoratedBox(decoration: const BoxDecoration(
                      color: Color.fromARGB(0, 0, 0, 0)
                  ),),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (direction) {
                    Navigator.pop(context);
                  },
                  key: key,
                  child: Material(
                    child: widget,
                  ));
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return SlideTransition(
                  position: new Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn)),
                  child: child);
            });
}
