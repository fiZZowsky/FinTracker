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
    context.push('/receipt-edit', extra: receipt).then((_) {
      _fetchData();
    });
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
    final iconColor = theme.colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildDetailRow(
          theme,
          iconWidget:
              (receipt.storeLogo != null && receipt.storeLogo!.isNotEmpty)
                  ? Image.memory(
                      receipt.storeLogo!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.store, size: 40, color: iconColor);
                      },
                    )
                  : Icon(Icons.store, size: 40, color: iconColor),
          label: l10n.receiptStoreName,
          value: receipt.storeName,
        ),
        const Divider(height: 24),
        if (receipt.categoryName != null &&
            receipt.categoryName!.isNotEmpty) ...[
          _buildDetailRow(
            theme,
            iconWidget:
                Icon(Icons.category_outlined, size: 28, color: iconColor),
            label: l10n.receiptCategory,
            value: receipt.categoryName!,
          ),
          const Divider(height: 24),
        ] else ...[
          _buildDetailRow(
            theme,
            iconWidget: const Icon(Icons.category_outlined,
                size: 28, color: Colors.grey),
            label: l10n.receiptCategory,
            value: l10n.noCategory,
            valueStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
          const Divider(height: 24),
        ],
        _buildDetailRow(
          theme,
          iconWidget: Icon(Icons.calendar_today, size: 28, color: iconColor),
          label: l10n.receiptDate,
          value: DateFormat('dd.MM.yyyy').format(receipt.dateShopping),
        ),
        const Divider(height: 24),
        _buildDetailRow(
          theme,
          iconWidget: Icon(Icons.paid, size: 28, color: iconColor),
          label: l10n.receiptTotalAmount,
          value: NumberFormat.simpleCurrency(name: receipt.currencyCode)
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
      {required Widget iconWidget,
      required String label,
      required String value,
      TextStyle? valueStyle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Center(child: iconWidget),
        ),
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
