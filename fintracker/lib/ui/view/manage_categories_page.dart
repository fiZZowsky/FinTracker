import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/manage_categories_view_model.dart';
import '../widgets/custom_loader.dart';

class ManageCategoriesPage extends StatefulWidget {
  const ManageCategoriesPage({super.key});

  @override
  State<ManageCategoriesPage> createState() => _ManageCategoriesPageState();
}

class _ManageCategoriesPageState extends State<ManageCategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManageCategoriesViewModel>().fetchCategories();
    });
  }

  void _showCategoryDialog({int? id, String? currentName}) {
    final controller = TextEditingController(text: currentName);
    final isEditing = id != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edytuj kategorię' : 'Nowa kategoria'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nazwa kategorii',
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

              final vm = context.read<ManageCategoriesViewModel>();
              bool success;
              if (isEditing) {
                success = await vm.editCategory(id, name);
              } else {
                success = await vm.addCategory(name);
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
    final vm = context.watch<ManageCategoriesViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategorie'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
      body: vm.isLoading
          ? const Center(child: CustomLoader())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.categories.length,
              itemBuilder: (context, index) {
                final category = vm.categories[index];

                final isDefault = category.isDefault;

                return Card(
                  color: isDefault
                      ? theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5)
                      : theme.cardColor,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      isDefault ? Icons.lock_outline : Icons.person_outline,
                      color:
                          isDefault ? Colors.grey : theme.colorScheme.primary,
                    ),
                    title: Text(
                      category.name,
                      style: TextStyle(
                        fontWeight:
                            isDefault ? FontWeight.normal : FontWeight.bold,
                        color: isDefault ? Colors.grey[700] : null,
                      ),
                    ),
                    subtitle: isDefault
                        ? const Text('Kategoria systemowa',
                            style: TextStyle(fontSize: 10))
                        : null,
                    trailing: isDefault
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _showCategoryDialog(
                                  id: category.id,
                                  currentName: category.name,
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
                                          'Czy usunąć kategorię "${category.name}"?'),
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
                                    await vm.deleteCategory(category.id);
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
