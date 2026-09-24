import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/clash_config.dart';
import 'package:bett_box/providers/config.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _UserAuthEntry {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  bool obscurePassword;

  _UserAuthEntry({
    required String username,
    required String password,
  })  : obscurePassword = true,
        usernameController = TextEditingController(text: username),
        passwordController = TextEditingController(text: password);

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}

class UserAuthDialog extends ConsumerStatefulWidget {
  const UserAuthDialog({super.key});

  @override
  ConsumerState<UserAuthDialog> createState() => _UserAuthDialogState();
}

class _UserAuthDialogState extends ConsumerState<UserAuthDialog> {
  final _formKey = GlobalKey<FormState>();
  late List<_UserAuthEntry> _entries;
  late bool _skipLocalAuth;

  @override
  void initState() {
    super.initState();
    final config = ref.read(patchClashConfigProvider);
    final auth = config.authentication;
    if (auth.isEmpty) {
      _entries = [];
    } else {
      _entries = auth.map((item) {
        final colonIdx = item.indexOf(':');
        if (colonIdx != -1) {
          return _UserAuthEntry(
            username: item.substring(0, colonIdx),
            password: item.substring(colonIdx + 1),
          );
        }
        return _UserAuthEntry(username: item, password: '');
      }).toList();
    }
    _skipLocalAuth =
        auth.isEmpty || config.skipAuthPrefixes.contains('127.0.0.1/8');
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() {
      _entries.add(_UserAuthEntry(username: '', password: ''));
    });
  }

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index).dispose();
    });
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() != true) return;

    final validUsers = <String>[];
    for (final entry in _entries) {
      final u = entry.usernameController.text.trim();
      final p = entry.passwordController.text;
      if (u.isNotEmpty && p.isNotEmpty) {
        validUsers.add('$u:$p');
      }
    }

    final nextPrefixes = _skipLocalAuth ? defaultSkipAuthPrefixes : <String>[];

    ref.read(patchClashConfigProvider.notifier).updateState(
          (state) => state.copyWith(
            authentication: validUsers,
            skipAuthPrefixes: nextPrefixes,
          ),
        );
    globalState.appController.setupClashConfigDebounce();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: appLocalizations.userAuth,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(appLocalizations.cancel),
        ),
        TextButton(
          onPressed: _handleSave,
          child: Text(appLocalizations.save),
        ),
      ],
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: _addEntry,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(appLocalizations.addUser),
                  ),
                ),
              )
            else ...[
              for (int i = 0; i < _entries.length; i++) ...[
                if (i > 0) const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_entries.length > 1)
                      Text(
                        '${appLocalizations.userAuth} ${i + 1}',
                        style: context.textTheme.labelMedium?.copyWith(
                          color: context.colorScheme.primary,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () => _removeEntry(i),
                      tooltip: appLocalizations.delete,
                    ),
                  ],
                ),
                TextFormField(
                  controller: _entries[i].usernameController,
                  decoration: InputDecoration(
                    labelText: appLocalizations.username,
                    prefixIcon: const Icon(Icons.person_outline),
                    isDense: true,
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return appLocalizations.emptyTip(appLocalizations.username);
                    }
                    if (trimmed.contains(':')) {
                      return appLocalizations.usernameCannotContainColon;
                    }
                    final hasDuplicate = _entries.asMap().entries.any(
                          (e) =>
                              e.key != i &&
                              e.value.usernameController.text.trim() == trimmed &&
                              trimmed.isNotEmpty,
                        );
                    if (hasDuplicate) {
                      return appLocalizations.existsTip(appLocalizations.username);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _entries[i].passwordController,
                  obscureText: _entries[i].obscurePassword,
                  decoration: InputDecoration(
                    labelText: appLocalizations.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _entries[i].obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _entries[i].obscurePassword =
                              !_entries[i].obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.emptyTip(appLocalizations.password);
                    }
                    return null;
                  },
                ),
              ],
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appLocalizations.skipLocalAuth,
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appLocalizations.skipLocalAuthDesc,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _skipLocalAuth,
                  onChanged: (val) {
                    setState(() {
                      _skipLocalAuth = val;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
