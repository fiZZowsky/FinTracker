import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/receipt_model.dart';

class ReceiptCard extends StatelessWidget {
  final ReceiptModel receipt;
  final VoidCallback onTap;

  const ReceiptCard({
    super.key,
    required this.receipt,
    required this.onTap,
  });

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.receipt;
    final cat = category.toLowerCase();
    if (cat.contains('spożyw')) return Icons.shopping_basket;
    if (cat.contains('transp') || cat.contains('paliwo')) {
      return Icons.local_gas_station;
    }
    if (cat.contains('restaur') || cat.contains('jedzenie')) {
      return Icons.restaurant;
    }
    if (cat.contains('dom')) return Icons.home;
    if (cat.contains('zdrow')) return Icons.medical_services;
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    (receipt.storeLogo != null && receipt.storeLogo!.isNotEmpty)
                        ? Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Image.memory(
                              receipt.storeLogo!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  _getCategoryIcon(receipt.categoryName),
                                  color: theme.colorScheme.primary,
                                );
                              },
                            ),
                          )
                        : Icon(
                            _getCategoryIcon(receipt.categoryName),
                            color: theme.colorScheme.primary,
                          ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receipt.storeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (receipt.categoryName != null)
                      Text(
                        receipt.categoryName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${NumberFormat.currency(symbol: '', decimalDigits: 2).format(receipt.totalAmount).trim()} ${receipt.currencyCode}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
