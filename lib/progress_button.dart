import 'package:flutter/material.dart';

import 'iconed_button.dart';

enum ButtonState { idle, loading, success, fail }

class ProgressButton extends StatefulWidget {
  final Map<ButtonState, Widget> stateWidgets;
  final Map<ButtonState, Color> stateColors;
  final Map<ButtonState, Color> stateDisabledColors;
  final Function? onPressed;
  final Function? onAnimationEnd;
  final ButtonState? state;
  final minWidth;
  final maxWidth;
  final radius;
  final height;
  final ProgressIndicator? progressIndicator;
  final progressIndicatorSize;
  final MainAxisAlignment progressIndicatorAligment;
  final EdgeInsets padding;
  final List<ButtonState> minWidthStates;
  final TextAlign? textAlign;

  ProgressButton(
      {Key? key,
      required this.stateWidgets,
      required this.stateColors,
      required this.stateDisabledColors,
      this.state = ButtonState.idle,
      this.onPressed,
      this.onAnimationEnd,
      this.minWidth = 200.0,
      this.maxWidth = 400.0,
      this.radius = 16.0,
      this.height = 53.0,
      this.progressIndicatorSize = 35.0,
      this.progressIndicator,
      this.textAlign,
      this.progressIndicatorAligment = MainAxisAlignment.spaceBetween,
      this.padding = EdgeInsets.zero,
      this.minWidthStates = const <ButtonState>[ButtonState.loading]})
      : assert(
          stateWidgets.keys.toSet().containsAll(ButtonState.values.toSet()),
          'Must be non-null widgetds provided in map of stateWidgets. Missing keys => ${ButtonState.values.toSet().difference(stateWidgets.keys.toSet())}',
        ),
        assert(
          stateColors.keys.toSet().containsAll(ButtonState.values.toSet()),
          'Must be non-null widgetds provided in map of stateWidgets. Missing keys => ${ButtonState.values.toSet().difference(stateColors.keys.toSet())}',
        ),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProgressButtonState();
  }

  factory ProgressButton.icon({
    required Map<ButtonState, IconedButton> iconedButtons,
    Function? onPressed,
    ButtonState? state = ButtonState.idle,
    Function? animationEnd,
    maxWidth: 170.0,
    minWidth: 58.0,
    height: 53.0,
    radius: 100.0,
    progressIndicatorSize: 35.0,
    double iconPadding: 4.0,
    TextStyle? textStyle,
    CircularProgressIndicator? progressIndicator,
    MainAxisAlignment? progressIndicatorAligment,
    EdgeInsets padding = EdgeInsets.zero,
    TextAlign? textAlign,
    List<ButtonState> minWidthStates = const <ButtonState>[ButtonState.loading],
  }) {
    assert(
      iconedButtons.keys.toSet().containsAll(ButtonState.values.toSet()),
      'Must be non-null widgets provided in map of stateWidgets. Missing keys => ${ButtonState.values.toSet().difference(iconedButtons.keys.toSet())}',
    );

    if (textStyle == null) {
      textStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.w500);
    }

    Map<ButtonState, Widget> stateWidgets = {
      ButtonState.idle: buildChildWithIcon(
          iconedButtons[ButtonState.idle]!, iconPadding, textStyle, textAlign),
      ButtonState.loading: Column(),
      ButtonState.fail: buildChildWithIcon(
          iconedButtons[ButtonState.fail]!, iconPadding, textStyle, textAlign),
      ButtonState.success: buildChildWithIcon(
          iconedButtons[ButtonState.success]!,
          iconPadding,
          textStyle,
          textAlign)
    };

    Map<ButtonState, Color> stateColors = {
      ButtonState.idle: iconedButtons[ButtonState.idle]!.color,
      ButtonState.loading: iconedButtons[ButtonState.loading]!.color,
      ButtonState.fail: iconedButtons[ButtonState.fail]!.color,
      ButtonState.success: iconedButtons[ButtonState.success]!.color,
    };

    Map<ButtonState, Color> stateDisabledColors = {
      ButtonState.idle: iconedButtons[ButtonState.idle]!.disabledColor,
      ButtonState.loading: iconedButtons[ButtonState.loading]!.disabledColor,
      ButtonState.fail: iconedButtons[ButtonState.fail]!.disabledColor,
      ButtonState.success: iconedButtons[ButtonState.success]!.disabledColor,
    };

    return ProgressButton(
      stateWidgets: stateWidgets,
      stateColors: stateColors,
      stateDisabledColors: stateDisabledColors,
      state: state,
      onPressed: onPressed,
      onAnimationEnd: animationEnd,
      maxWidth: maxWidth,
      minWidth: minWidth,
      radius: radius,
      height: height,
      progressIndicatorSize: progressIndicatorSize,
      progressIndicatorAligment: MainAxisAlignment.center,
      progressIndicator: progressIndicator,
      minWidthStates: minWidthStates,
    );
  }
}

class _ProgressButtonState extends State<ProgressButton>
    with TickerProviderStateMixin {
  AnimationController? colorAnimationController;
  Animation<Color?>? colorAnimation;
  double? width;
  Duration animationDuration = Duration(milliseconds: 500);
  Widget? progressIndicator;

  void startAnimations(ButtonState? oldState, ButtonState? newState) {
    Color? begin = widget.stateColors[oldState!];
    Color? end = widget.stateColors[newState!];
    if (widget.minWidthStates.contains(newState)) {
      width = widget.minWidth;
    } else {
      width = widget.maxWidth;
    }
    colorAnimation = ColorTween(begin: begin, end: end).animate(CurvedAnimation(
      parent: colorAnimationController!,
      curve: Interval(
        0,
        1,
        curve: Curves.easeIn,
      ),
    ));
    colorAnimationController!.forward();
  }

  Color? get backgroundColor => colorAnimation == null
      ? widget.stateColors[widget.state!]
      : colorAnimation!.value ?? widget.stateColors[widget.state!];

  Color? get disabledBackgroundColor =>
      widget.stateDisabledColors[widget.state!];

  @override
  void initState() {
    super.initState();

    width = widget.maxWidth;

    colorAnimationController =
        AnimationController(duration: animationDuration, vsync: this);
    colorAnimationController!.addStatusListener((status) {
      if (widget.onAnimationEnd != null) {
        widget.onAnimationEnd!(status, widget.state);
      }
    });

    progressIndicator = widget.progressIndicator ??
        CircularProgressIndicator(
            backgroundColor: widget.stateColors[widget.state!],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
  }

  @override
  void dispose() {
    colorAnimationController!.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ProgressButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.state != widget.state) {
      colorAnimationController?.reset();
      startAnimations(oldWidget.state, widget.state);
    }
  }

  Widget getButtonChild(bool visibility) {
    Widget? buttonChild = widget.stateWidgets[widget.state!];
    if (widget.state == ButtonState.loading) {
      return Row(
        mainAxisAlignment: widget.progressIndicatorAligment,
        children: <Widget>[
          SizedBox(
            child: progressIndicator,
            width: widget.progressIndicatorSize,
            height: widget.progressIndicatorSize,
          ),
          buttonChild ?? Container(),
          Container()
        ],
      );
    }
    return AnimatedOpacity(
        opacity: visibility ? 1.0 : 0.0,
        duration: Duration(milliseconds: 250),
        child: buttonChild);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: colorAnimationController!,
      builder: (context, child) {
        return AnimatedContainer(
            width: width,
            height: widget.height,
            duration: animationDuration,
            child: MaterialButton(
              elevation: 0,
              disabledElevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              hoverElevation: 0,
              padding: widget.padding,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.radius),
                  side: BorderSide(color: Colors.transparent, width: 0)),
              color: backgroundColor,
              disabledColor: disabledBackgroundColor,
              onPressed: widget.onPressed as void Function()?,
              child: getButtonChild(
                  colorAnimation == null ? true : colorAnimation!.isCompleted),
            ));
      },
    );
  }
}
