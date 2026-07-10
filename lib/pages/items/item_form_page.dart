import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../categories/categories_store.dart';
import '../../items/items_store.dart';
import '../../models/category.dart';
import '../../models/item.dart';

class ItemFormPage extends StatefulWidget {
  const ItemFormPage({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    this.initial,
  });

  final String title;
  final String submitLabel;
  final Item? initial;
  final Future<Item?> Function(Item item) onSubmit;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _priceCtrl = TextEditingController(text: item == null ? '' : item.price.toStringAsFixed(2));
    _descCtrl = TextEditingController(text: item?.description ?? '');
    _categoryId = item?.categoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoriesStore>().refresh();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final item = Item(
      name: _nameCtrl.text.trim(),
      price: price,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      categoryId: _categoryId,
    );
    final result = await widget.onSubmit(item);
    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<ItemsStore>().error ?? 'Request failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ItemsStore>();
    final categories = context.watch<CategoriesStore>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: store.loading ? null : _submit,
            child: store.loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(widget.submitLabel),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceCtrl,
              decoration: const InputDecoration(labelText: 'Price', prefixText: '\$'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final parsed = double.tryParse(v?.trim() ?? '');
                if (parsed == null || parsed <= 0) return 'Enter a price greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              value: _categoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('Uncategorized')),
                ...categories.categories.map(
                  (Category c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
                ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              minLines: 2,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCreatePage extends StatelessWidget {
  const ItemCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ItemFormPage(
      title: 'Create item',
      submitLabel: 'Create',
      onSubmit: (item) => context.read<ItemsStore>().create(item),
    );
  }
}

class ItemEditPage extends StatelessWidget {
  const ItemEditPage({super.key, required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return ItemFormPage(
      title: 'Edit item',
      submitLabel: 'Save',
      initial: item,
      onSubmit: (updated) => context.read<ItemsStore>().update(item.id!, updated),
    );
  }
}
