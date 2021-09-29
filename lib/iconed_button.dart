import 'package:flutter/material.dart';

class IconedButton {
  final String? text;
  final Icon? icon;
  final Color color;
  final Color disabledColor;

  const IconedButton({
    this.text,
    this.icon,
    this.disabledColor = Colors.transparent,
    required this.color,
  });
}

Widget buildChildWithIcon(IconedButton iconedButton, double iconPadding,
    TextStyle textStyle, TextAlign? textAlign) {
  return buildChildWithIC(
      iconedButton.text, iconedButton.icon, iconPadding, textStyle, textAlign);
}

Widget buildChildWithIC(String? text, Icon? icon, double gap,
    TextStyle textStyle, TextAlign? textAlign) {
  var children = <Widget>[];
  children.add(icon ?? Container());
  if (text != null) {
    children.add(Padding(padding: EdgeInsets.all(gap)));
    children.add(
      buildText(
        text,
        textStyle,
        textAlign,
      ),
    );
  }

  return Wrap(
    direction: Axis.horizontal,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
}

Widget buildText(String text, TextStyle style, TextAlign? textAlign) {
  return Text(
    text,
    style: style,
    textAlign: textAlign,
  );
}
