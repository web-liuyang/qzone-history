import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  const Loading({
    super.key,
    required this.loading,
    required this.child,
  });

  final bool loading;

  final Widget child;

  @override
  LoadingState createState() => LoadingState();
}

class LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.loading)
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.1),
              child: const CircularProgressIndicator(),
            ),
          )
      ],
    );
  }
}
