import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fintracker/l10n/app_localizations.dart';
import '../../data/models/receipt_model.dart';
import '../view_models/receipt_edit_view_model.dart';
import '../view_models/finanses_view_model.dart';
import '../../helpers/notification_service.dart';
import '../../helpers/service_locator.dart';
import '../widgets/custom_loader.dart';
import '../view_models/receipt_details_view_model.dart';
import '../view_models/navigation_guard_view_model.dart';

class ReceiptEditPage extends StatefulWidget {
  final ReceiptModel receipt;

  const ReceiptEditPage({super.key, required this.receipt});

  @override
  State<ReceiptEditPage> createState() => _ReceiptEditPageState();
}

class _ReceiptEditPageState extends State<ReceiptEditPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _storeNameController;
  late final TextEditingController _totalAmountController;
  late DateTime _dateShopping;

  late NavigationGuardViewModel _navGuard;
  bool _isNavGuardInitialized = false;

  @override
  void initState() {
    super.initState();
    _storeNameController =
        TextEditingController(text: widget.receipt.storeName);
    _totalAmountController = TextEditingController(
        text: widget.receipt.totalAmount.toStringAsFixed(2));
    _dateShopping = widget.receipt.dateShopping;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isNavGuardInitialized) {
      _navGuard = context.read<NavigationGuardViewModel>();
      _navGuard.setEditing(true);
      _isNavGuardInitialized = true;
    }
  }

  @override
  void dispose() {
    _navGuard.setEditing(false);

    _storeNameController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dateShopping,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && pickedDate != _dateShopping) {
      setState(() {
        _dateShopping = pickedDate;
      });
    }
  }

  Future<void> _saveReceipt() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<ReceiptEditViewModel>();
    final notificationService = getIt<NotificationService>();
    final guard = context.read<NavigationGuardViewModel>();

    final totalAmount =
        double.tryParse(_totalAmountController.text.replaceAll(',', '.')) ??
            0.0;

    // Tworzymy model, zachowując oryginalne ID (jeśli istnieje)
    final updatedReceipt = ReceiptModel(
      id: widget.receipt.id, // Ważne: zachowujemy ID (będzie 0 dla nowych)
      storeName: _storeNameController.text,
      totalAmount: totalAmount,
      dateShopping: _dateShopping,
    );

    final success = await viewModel.saveReceipt(updatedReceipt);

    if (mounted) {
      if (success) {
        guard.setEditing(false);
        final messageKey = widget.receipt.id > 0
            ? 'receiptUpdateSuccess'
            : 'receiptSaveSuccess';
        notificationService.showNotification(messageKey,
            type: NotificationType.success);

        await context.read<FinansesViewModel>().fetchData();

        if (widget.receipt.id > 0) {
          await context
              .read<ReceiptDetailsViewModel>()
              .fetchReceiptDetails(widget.receipt.id);
          context.pop();
        } else {
          context.go('/finanses');
        }
      } else {
        // BŁĄD
        final messageKey =
            widget.receipt.id > 0 ? 'receiptUpdateError' : 'receiptSaveError';
        notificationService.showNotification(messageKey,
            type: NotificationType.error);
      }
    }
  }

  Future<void> _onWillPop(bool didPop) async {
    if (didPop) {
      return;
    }

    final guard = context.read<NavigationGuardViewModel>();
    final bool canPop = await guard.canNavigate(context);

    if (canPop && context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLoading = context.watch<ReceiptEditViewModel>().isLoading;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.receipt.id > 0
              ? l10n.receiptEditTitle
              : "Dodaj Paragon"), // TODO: Dodaj "Dodaj Paragon" do .arb
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _storeNameController,
                      decoration: InputDecoration(
                        labelText: l10n.receiptStoreName,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.fieldRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _totalAmountController,
                      decoration: InputDecoration(
                        labelText: l10n.receiptTotalAmount,
                        suffixText: 'PLN',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.fieldRequired;
                        }
                        if (double.tryParse(value.replaceAll(',', '.')) ==
                            null) {
                          return 'Nieprawidłowa wartość'; // TODO: Przenieść do .arb
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(l10n.receiptDate),
                      subtitle: Text(DateFormat.yMd().format(_dateShopping)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _pickDate(context),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _saveReceipt,
                      icon: const Icon(Icons.save),
                      label: Text(l10n.receiptSaveButton),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CustomLoader(size: 80),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
