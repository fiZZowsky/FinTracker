import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/scanner_view_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

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
              onPressed: scannerVM.scanWithCamera,
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
              onPressed: scannerVM.pickFile,
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
