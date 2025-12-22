import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fintracker/l10n/app_localizations.dart';

class BudgetBar extends StatelessWidget {
  final double spent;
  final double limit;

  const BudgetBar({
    super.key,
    required this.spent,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final double percentage = (spent / limit).clamp(0.0, 1.0);
    final double remaining = limit - spent;

    Color progressColor = theme.colorScheme.primary;
    if (percentage > 0.75) progressColor = Colors.orange;
    if (percentage >= 1.0) progressColor = theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.budgetRemaining,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: Colors.grey),
                  ),
                  Text(
                    NumberFormat.simpleCurrency(locale: 'pl_PL')
                        .format(remaining),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: remaining < 0
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(percentage * 100).toInt()}%',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                  Text(
                    '${l10n.budgetLimit}: ${NumberFormat.compactSimpleCurrency(locale: 'pl_PL').format(limit)}',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}
