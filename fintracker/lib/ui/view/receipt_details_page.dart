import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:fintracker/l10n/app_localizations.dart';

import '../view_models/receipt_details_view_model.dart';
import '../widgets/custom_loader.dart';
import '../../data/models/receipt_model.dart';

class ReceiptDetailsPage extends StatefulWidget {
  final int receiptId;
  const ReceiptDetailsPage({super.key, required this.receiptId});

  @override
  State<ReceiptDetailsPage> createState() => _ReceiptDetailsPageState();
}

class _ReceiptDetailsPageState extends State<ReceiptDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    context
        .read<ReceiptDetailsViewModel>()
        .fetchReceiptDetails(widget.receiptId);
  }

  void _navigateToEdit(BuildContext context, ReceiptModel receipt) {
    context.push('/receipt-edit', extra: receipt);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final viewModel = context.watch<ReceiptDetailsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receiptDetails),
        actions: [
          if (viewModel.receipt != null && !viewModel.isLoading)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n.edit,
              onPressed: () => _navigateToEdit(context, viewModel.receipt!),
            ),
        ],
      ),
      body: _buildBody(context, viewModel, l10n),
    );
  }

  Widget _buildBody(BuildContext context, ReceiptDetailsViewModel viewModel,
      AppLocalizations l10n) {
    if (viewModel.isLoading) {
      return const Center(child: CustomLoader(size: 80));
    }

    if (viewModel.hasError || viewModel.receipt == null) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.errorFetchingData),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchData,
            child: Text(l10n.tryAgain),
          )
        ],
      ));
    }

    final receipt = viewModel.receipt!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildDetailRow(
          theme,
          icon: Icons.store,
          label: l10n.receiptStoreName,
          value: receipt.storeName,
        ),
        const Divider(height: 24),
        _buildDetailRow(
          theme,
          icon: Icons.calendar_today,
          label: l10n.receiptDate,
          value: DateFormat.yMd().format(receipt.dateShopping),
        ),
        const Divider(height: 24),
        _buildDetailRow(
          theme,
          icon: Icons.paid,
          label: l10n.receiptTotalAmount,
          value: NumberFormat.simpleCurrency(locale: 'pl_PL')
              .format(receipt.totalAmount),
          valueStyle: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(ThemeData theme,
      {required IconData icon,
      required String label,
      required String value,
      TextStyle? valueStyle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: valueStyle ?? theme.textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
