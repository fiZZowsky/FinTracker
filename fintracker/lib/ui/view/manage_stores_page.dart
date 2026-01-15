import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/manage_stores_view_model.dart';
import '../widgets/custom_loader.dart';

class ManageStoresPage extends StatefulWidget {
  const ManageStoresPage({super.key});

  @override
  State<ManageStoresPage> createState() => _ManageStoresPageState();
}

class _ManageStoresPageState extends State<ManageStoresPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageStoresViewModel>().fetchStores();
    });
  }

  void _showStoreDialog({int? id, String? currentName}) {
    final controller = TextEditingController(text: currentName);
    final isEditing = id != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edytuj sklep' : 'Nowy sklep'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nazwa sklepu',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;

              final vm = context.read<ManageStoresViewModel>();
              bool success;
              if (isEditing) {
                success = await vm.editStore(id, name);
              } else {
                success = await vm.addStore(name);
              }

              if (ctx.mounted) {
                Navigator.pop(ctx);
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wystąpił błąd')),
                  );
                }
              }
            },
            child: const Text('Zapisz'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManageStoresViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moje Sklepy'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showStoreDialog(),
        child: const Icon(Icons.add),
      ),
      body: vm.isLoading
          ? const Center(child: CustomLoader())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.stores.length,
              itemBuilder: (context, index) {
                final store = vm.stores[index];
                final isDefault = store.isDefault;

                return Card(
                  color: isDefault
                      ? theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5)
                      : theme.cardColor,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: (store.logo != null && store.logo!.isNotEmpty)
                          ? Image.memory(
                              store.logo!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.store,
                                    color: theme.colorScheme.primary);
                              },
                            )
                          : Icon(Icons.store, color: theme.colorScheme.primary),
                    ),
                    title: Text(
                      store.name,
                      style: TextStyle(
                        fontWeight:
                            isDefault ? FontWeight.normal : FontWeight.bold,
                        color: isDefault ? Colors.grey[700] : null,
                      ),
                    ),
                    subtitle: isDefault
                        ? const Text('Systemowy',
                            style: TextStyle(fontSize: 10))
                        : null,
                    trailing: isDefault
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showStoreDialog(
                                  id: store.id,
                                  currentName: store.name,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 20, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Potwierdzenie'),
                                      content: Text(
                                          'Czy usunąć sklep "${store.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Nie'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Tak'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await vm.deleteStore(store.id);
                                  }
                                },
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
    );
  }
}
