import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../categories/categories_store.dart';
import '../../models/category.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    this.initial,
  });

  final String title;
  final String submitLabel;
  final Category? initial;
  final Future<Category?> Function(Category category) onSubmit;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial?.name ?? '');
    _descCtrl = TextEditingController(text: widget.initial?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final category = Category(
      id: widget.initial?.id ?? 0,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
    );
    final result = await widget.onSubmit(category);
    if (!mounted) return;
    if (result != null) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<CategoriesStore>().error ?? 'Request failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CategoriesStore>();
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
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)'),
              minLines: 2,
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCreatePage extends StatelessWidget {
  const CategoryCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CategoryFormPage(
      title: 'Create category',
      submitLabel: 'Create',
      onSubmit: (category) => context.read<CategoriesStore>().create(category),
    );
  }
}

class CategoryEditPage extends StatelessWidget {
  const CategoryEditPage({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return CategoryFormPage(
      title: 'Edit category',
      submitLabel: 'Save',
      initial: category,
      onSubmit: (updated) => context.read<CategoriesStore>().update(category.id, updated),
    );
  }
}
