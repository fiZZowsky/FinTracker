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
import '../view_models/stores_view_model.dart';
import '../../data/models/store_model.dart';

class ReceiptEditPage extends StatefulWidget {
  final ReceiptModel receipt;

  const ReceiptEditPage({super.key, required this.receipt});

  @override
  State<ReceiptEditPage> createState() => _ReceiptEditPageState();
}

class _ReceiptEditPageState extends State<ReceiptEditPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStoreName;
  late final TextEditingController _totalAmountController;
  late DateTime _dateShopping;

  late NavigationGuardViewModel _navGuard;
  bool _isNavGuardInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.receipt.storeName.isNotEmpty) {
      _selectedStoreName = widget.receipt.storeName;
    }
    _totalAmountController = TextEditingController(
        text: widget.receipt.totalAmount.toStringAsFixed(2));
    _dateShopping = widget.receipt.dateShopping;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoresViewModel>().fetchStores();
    });
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

    final updatedReceipt = ReceiptModel(
        id: widget.receipt.id,
        storeName: _selectedStoreName!,
        totalAmount: totalAmount,
        dateShopping: _dateShopping,
        storeLogo: null);

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
    final storesVM = context.watch<StoresViewModel>();
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.receipt.id > 0
              ? l10n.receiptEditTitle
              : l10n.receiptAddTitle),
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (storesVM.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(child: CustomLoader(size: 50)),
                      )
                    else
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildSelectedStoreLogo(storesVM, _selectedStoreName),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _isValidStore(
                                      storesVM.stores, _selectedStoreName)
                                  ? _selectedStoreName
                                  : null,
                              decoration: InputDecoration(
                                labelText: l10n.receiptStoreName,
                                border: const OutlineInputBorder(),
                              ),
                              items: storesVM.stores.map((StoreModel store) {
                                return DropdownMenuItem<String>(
                                  value: store.name,
                                  child: Text(store.name),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStoreName = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.fieldRequired;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
                          return l10n.invalidValue;
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

  bool _isValidStore(List<StoreModel> stores, String? name) {
    if (name == null) return false;
    return stores.any((s) => s.name == name);
  }

  Widget _buildSelectedStoreLogo(StoresViewModel vm, String? storeName) {
    Widget content = const Icon(Icons.store, size: 30, color: Colors.grey);

    if (storeName != null) {
      final store = vm.findByName(storeName);
      if (store?.logo != null) {
        content = Image.memory(store!.logo!,
            width: 40, height: 40, fit: BoxFit.contain);
      }
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: content),
    );
  }
}
