import 'package:flutter/material.dart';
import 'package:qzone/widgets/widgets.dart';

class DialogLayout extends StatefulWidget {
  const DialogLayout({
    super.key,
    this.title,
    this.content,
    required this.onClose,
  });

  final Widget? title;

  final Widget? content;

  final VoidCallback onClose;

  @override
  _DialogLayoutState createState() => _DialogLayoutState();
}

class _DialogLayoutState extends State<DialogLayout> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SpacedWidget(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              widget.title != null ? widget.title! : const SizedBox.shrink(),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (widget.content != null) widget.content!,
        ],
      ),
    );
  }
}
