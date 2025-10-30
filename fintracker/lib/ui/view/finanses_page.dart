import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/finanses_view_model.dart';
import '../widgets/custom_loader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FinansesPage extends StatelessWidget {
  const FinansesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<FinansesViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CustomLoader(size: 100),
          );
        }

        if (viewModel.hasError) {
          return Center(
            child: Text(
              l10n.errorFetchingData,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        if (viewModel.receipts.isEmpty) {
          return Center(
            child: Text(
              l10n.noReceiptsAdded,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: viewModel.receipts.length,
          itemBuilder: (context, index) {
            final receipt = viewModel.receipts[index];

            return ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(receipt.storeName),
              subtitle: Text(
                '${receipt.dateShopping.day}.${receipt.dateShopping.month}.${receipt.dateShopping.year}',
              ),
              trailing: Text(
                '${receipt.totalAmount.toStringAsFixed(2)} zł',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              onTap: () {
                // TODO: Nawigacja do szczegółów paragonu
              },
            );
          },
        );
      },
    );
  }
}
