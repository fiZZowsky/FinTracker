import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fintracker/l10n/app_localizations.dart';

import '../view_models/finanses_view_model.dart';
import '../../data/models/receipt_model.dart';
import '../widgets/custom_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<FinansesViewModel>();
      vm.fetchData();
      vm.fetchRecentReceipts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.fintracker),
        elevation: 0,
      ),
      body: Consumer<FinansesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CustomLoader(size: 80));
          }

          final double currentTotal = viewModel.currentMonthTotal;
          final recentReceipts = viewModel.recentReceipts;

          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchData();
              await viewModel.fetchRecentReceipts();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(theme, l10n),
                  const SizedBox(height: 20),
                  _buildSummaryCard(
                      theme, currentTotal, l10n, viewModel.currentCurrency),
                  const SizedBox(height: 24),
                  _buildQuickActions(context, l10n),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.recentReceipts,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/finanses'),
                        child: Text(l10n.finansesAllTab),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (recentReceipts.isEmpty)
                    _buildEmptyState(context, l10n)
                  else
                    _buildRecentList(context, recentReceipts, theme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection(ThemeData theme, AppLocalizations l10n) {
    final now = DateTime.now();
    final dateString = DateFormat.yMMMMEEEEd(l10n.localeName).format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateString,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.welcomeBack,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(ThemeData theme, double total, AppLocalizations l10n,
      String currencyCode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.finansesTotal,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${NumberFormat.currency(symbol: '', decimalDigits: 2).format(total).trim()} $currencyCode',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.currentMonth,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.go('/scanner'),
            icon: const Icon(Icons.qr_code_scanner),
            label: Text(l10n.scanAction),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/receipt-edit',
                extra: ReceiptModel(
                    id: 0,
                    storeName: '',
                    totalAmount: 0,
                    dateShopping: DateTime.now(),
                    storeLogo: null)),
            icon: const Icon(Icons.add),
            label: Text(l10n.addAction),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentList(
      BuildContext context, List<ReceiptModel> receipts, ThemeData theme) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: receipts.length,
      separatorBuilder: (ctx, i) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final receipt = receipts[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: receipt.storeLogo != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Image.memory(receipt.storeLogo!, fit: BoxFit.contain),
                  )
                : Icon(Icons.store, color: theme.colorScheme.primary),
          ),
          title: Text(
            receipt.storeName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            DateFormat.MMMd(l10n.localeName).format(receipt.dateShopping),
            style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          trailing: Text(
            '${NumberFormat.currency(symbol: '', decimalDigits: 2).format(receipt.totalAmount).trim()} ${receipt.currencyCode}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              fontSize: 16,
            ),
          ),
          onTap: () {
            context.push('/receipt-details/${receipt.id}');
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            l10n.noReceiptsAdded,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
