import 'package:flutter/material.dart';

class ApprovalDialog extends StatelessWidget {
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const ApprovalDialog({super.key, this.onApprove, this.onReject});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Approve or Reject'),
      content: const Text('This is a placeholder approval dialog.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onReject?.call();
          },
          child: const Text('Reject'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onApprove?.call();
          },
          child: const Text('Approve'),
        ),
      ],
    );
  }
}

