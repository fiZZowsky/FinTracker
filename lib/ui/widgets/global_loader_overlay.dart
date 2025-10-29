import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/loading_view_model.dart';
import 'custom_loader.dart';

class GlobalLoaderOverlay extends StatelessWidget {
  const GlobalLoaderOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingViewModel>(
      builder: (context, loadingVM, child) {
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: loadingVM.isLoading ? 1.0 : 0.0,
          child: IgnorePointer(
            ignoring: !loadingVM.isLoading,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3),
              child: const Center(
                child: CustomLoader(size: 100),
              ),
            ),
          ),
        );
      },
    );
  }
}
