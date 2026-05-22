import 'package:flutter/material.dart';

class InvoiceStatusChip extends StatelessWidget {
  final String status;

  const InvoiceStatusChip({super.key, required this.status});

  Color _chipColor() {
    final s = status.toLowerCase();
    if (s.contains('approved')) return Colors.green;
    if (s.contains('pending')) return Colors.orange;
    if (s.contains('rejected')) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final color = _chipColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

