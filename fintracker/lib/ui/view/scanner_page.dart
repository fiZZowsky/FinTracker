import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/scanner_view_model.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scannerVM = context.read<ScannerViewModel>();
    // final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.camera_alt, size: 100),
          const SizedBox(height: 20),
          Text(
            "Użyj aparatu, aby zeskanować paragon", // TODO: l10n
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: scannerVM.scanWithCamera,
            icon: const Icon(Icons.camera),
            label: Text("Uruchom aparat"), // TODO: l10n
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
