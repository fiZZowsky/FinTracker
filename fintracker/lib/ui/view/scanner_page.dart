import 'package:fintracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/scanner_view_model.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/receipt_model.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  Future<void> _handleScan(
    BuildContext context,
    Future<ReceiptModel?> Function() scanFunction,
  ) async {
    final receipt = await scanFunction();

    if (context.mounted && receipt != null) {
      context.push('/receipt-edit', extra: receipt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerVM = context.read<ScannerViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt, size: 100),
            const SizedBox(height: 20),
            Text(
              l10n.scannerTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _handleScan(context, scannerVM.scanWithCamera),
              icon: const Icon(Icons.camera),
              label: Text(l10n.scannerCameraAccess),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _handleScan(context, scannerVM.pickFile),
              icon: const Icon(Icons.image_outlined),
              label: Text(l10n.scannerGalleryAccess),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
