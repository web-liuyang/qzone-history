import 'package:flutter/widgets.dart';

class NumberedContainer extends StatelessWidget {
  const NumberedContainer({
    super.key,
    required this.number,
    required this.child,
  });

  final int number;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 12,
          right: 12,
          child: Text("#$number"),
        )
      ],
    );
  }
}
