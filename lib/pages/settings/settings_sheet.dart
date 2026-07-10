import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_config.dart';
import '../../auth/auth_store.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late final TextEditingController _baseUrlCtrl;

  @override
  void initState() {
    super.initState();
    final config = context.read<AppConfig>();
    _baseUrlCtrl = TextEditingController(text: config.baseUrl);
  }

  @override
  void dispose() {
    _baseUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<AppConfig>();
    final auth = context.watch<AuthStore>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: config.useMock,
              onChanged: config.setUseMock,
              title: const Text('Use mock data'),
              subtitle: const Text('Turn off to call a live *-101 API'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _baseUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                hintText: 'http://localhost:8000',
              ),
              onChanged: config.setBaseUrl,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(auth.isAuthenticated ? 'Signed in as ${auth.user?.email}' : 'Not signed in'),
              subtitle: const Text('Required for create, update, and delete'),
              trailing: TextButton(
                onPressed: auth.isAuthenticated ? auth.logout : null,
                child: const Text('Sign out'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
