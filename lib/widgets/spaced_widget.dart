import 'package:flutter/widgets.dart';

enum SpacingAlignment { between, evenly }

class SpacedWidget extends StatelessWidget {
  const SpacedWidget({
    super.key,
    this.spacing = 8,
    this.spacingAlignment = SpacingAlignment.between,
    this.direction = Axis.vertical,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.clipBehavior = Clip.none,
    required this.children,
  });

  final num spacing;
  final SpacingAlignment spacingAlignment;
  final Axis direction;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final Clip clipBehavior;
  final List<Widget> children;

  static List<Widget> insertSpacer(List<Widget> children, Axis axis, num spacing, SpacingAlignment spacingAlignment) {
    if (children.isEmpty) return [];

    final Widget spacingWidget = SpacedWidget.spacingWidget(axis, spacing);
    return switch (spacingAlignment) {
      SpacingAlignment.between => SpacedWidget.insertSpacerByBetween(children, spacingWidget),
      SpacingAlignment.evenly => SpacedWidget.insertSpacerByEvenly(children, spacingWidget),
    };
  }

  static List<Widget> insertSpacerByBetween(List<Widget> children, Widget spacingWidget) {
    final List<Widget> widgets = [];

    for (int i = 0, len = children.length; i < len; i++) {
      widgets.addAll([children[i], spacingWidget]);
    }

    widgets.removeLast();

    return widgets;
  }

  static List<Widget> insertSpacerByEvenly(List<Widget> children, Widget spacingWidget) {
    final List<Widget> widgets = [spacingWidget];

    for (int i = 0, len = children.length; i < len; i++) {
      widgets.addAll([children[i], spacingWidget]);
    }

    return widgets;
  }

  static Widget spacingWidget(Axis axis, num spacing) {
    return switch (axis) {
      Axis.horizontal => SizedBox(width: spacing.toDouble()),
      Axis.vertical => SizedBox(height: spacing.toDouble()),
    };
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = SpacedWidget.insertSpacer(children, direction, spacing, spacingAlignment);

    return Flex(
      key: key,
      direction: direction,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      textBaseline: textBaseline,
      clipBehavior: clipBehavior,
      children: widgets,
    );
  }
}
