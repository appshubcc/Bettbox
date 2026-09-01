import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/common.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/dialog.dart';
import 'package:bett_box/widgets/null_status.dart';
import 'package:bett_box/widgets/text.dart';
import 'package:flutter/material.dart';

import 'card.dart';
import 'effect.dart';
import 'float_layout.dart';
import 'list.dart';

class OptionsDialog<T> extends StatelessWidget {
  final String title;
  final List<T> options;
  final T value;
  final String Function(T value) textBuilder;

  const OptionsDialog({
    super.key,
    required this.title,
    required this.options,
    required this.textBuilder,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: title,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop(option);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        value == option
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 21,
                        color: value == option
                            ? context.colorScheme.primary
                            : context.colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: value == option
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: EmojiText(
                                  textBuilder(option),
                                  style: context.textTheme.bodyMedium,
                                ),
                              )
                            : EmojiText(
                                textBuilder(option),
                                style: context.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CommonCheckBox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool isCircle;

  const CommonCheckBox({
    required this.value,
    required this.onChanged,
    this.isCircle = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      shape: isCircle ? const CircleBorder() : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

class InputDialog extends StatefulWidget {
  final String title;
  final String value;
  final String? suffixText;
  final String? labelText;
  final String? resetValue;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final bool? obscureText;
  final bool autofocus;
  final bool delayedFocus;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  const InputDialog({
    super.key,
    required this.title,
    required this.value,
    this.suffixText,
    this.resetValue,
    this.hintText,
    this.validator,
    this.obscureText,
    this.labelText,
    this.autofocus = false,
    this.delayedFocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController textController;
  FocusNode? _focusNode;

  String get value => widget.value;

  String get title => widget.title;

  String? get suffixText => widget.suffixText;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: value);
    if (widget.delayedFocus) {
      _focusNode = FocusNode();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _focusNode?.requestFocus();
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    textController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    final text = textController.value.text;
    Navigator.of(context).pop<String>(text);
  }

  Future<void> _handleReset() async {
    if (widget.resetValue == null) {
      return;
    }
    Navigator.of(context).pop<String>(widget.resetValue);
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: title,
      actions: [
        if (widget.resetValue != null &&
            textController.value.text != widget.resetValue) ...[
          TextButton(
            onPressed: _handleReset,
            child: Text(appLocalizations.reset),
          ),
          const SizedBox(width: 4),
        ],
        TextButton(
          onPressed: _handleUpdate,
          child: Text(appLocalizations.submit),
        ),
      ],
      child: Form(
        autovalidateMode: widget.autovalidateMode,
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            TextFormField(
              autofocus: widget.autofocus && !widget.delayedFocus,
              focusNode: _focusNode,
              obscureText: widget.obscureText ?? false,
              keyboardType: widget.keyboardType ??
                  (widget.obscureText == true
                      ? TextInputType.visiblePassword
                      : TextInputType.text),
              textInputAction: widget.textInputAction ?? TextInputAction.done,
              maxLines: widget.obscureText == true ? 1 : widget.maxLines,
              minLines: 1,
              controller: textController,
              onFieldSubmitted: (_) {
                _handleUpdate();
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                suffixText: suffixText,
                hintText: widget.hintText,
                labelText: widget.labelText,
              ),
              validator: widget.validator,
            ),
          ],
        ),
      ),
    );
  }
}

class ListInputPage extends StatelessWidget {
  final String title;
  final List<String> items;
  final Widget Function(String item) titleBuilder;
  final Widget Function(String item)? subtitleBuilder;
  final Widget Function(String item)? leadingBuilder;
  final String? valueLabel;
  final Function(List<String> items) onChange;

  const ListInputPage({
    super.key,
    required this.title,
    required this.items,
    required this.titleBuilder,
    required this.onChange,
    this.leadingBuilder,
    this.valueLabel,
    this.subtitleBuilder,
  });

  Future<void> _handleAddOrEdit([String? item]) async {
    uniqueValidator(String? value) {
      final index = items.indexWhere((entry) {
        return entry == value;
      });
      final current = item == value;
      if (index != -1 && !current) {
        return appLocalizations.existsTip(appLocalizations.value);
      }
      return null;
    }

    final valueField = Field(
      label: valueLabel ?? appLocalizations.value,
      value: item ?? '',
      validator: uniqueValidator,
    );
    final value = await globalState.showCommonDialog<String>(
      child: AddDialog(valueField: valueField, title: title),
    );
    if (value == null) return;
    final index = items.indexWhere((entry) {
      return entry == item;
    });
    final nextItems = List<String>.from(items);
    if (item != null) {
      nextItems[index] = value;
    } else {
      nextItems.add(value);
    }
    onChange(nextItems);
  }

  void _handleDelete(String? item) {
    final entries = List<String>.from(items);
    final index = entries.indexWhere((entry) {
      return entry == item;
    });
    if (index != -1) {
      entries.removeAt(index);
    }
    onChange(entries);
  }

  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: FloatingActionButton(
          onPressed: () async {
            _handleAddOrEdit();
          },
          child: const Icon(Icons.add),
        ),
      ),
      child: items.isEmpty
          ? NullStatus(label: appLocalizations.noData)
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 16 + 64),
              buildDefaultDragHandles: false,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final e = items[index];
                return _InputItem(
                  key: ValueKey(e),
                  ReorderableDelayedDragStartListener(
                    index: index,
                    child: CommonCard(
                      child: ListItem(
                        leading: leadingBuilder != null
                            ? leadingBuilder!(e)
                            : null,
                        title: titleBuilder(e),
                        subtitle: subtitleBuilder != null
                            ? subtitleBuilder!(e)
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            _handleDelete(e);
                          },
                        ),
                      ),
                      onPressed: () {
                        _handleAddOrEdit(e);
                      },
                    ),
                  ),
                );
              },
              // ignore: deprecated_member_use
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final nextItems = List<String>.from(items);
                final item = nextItems.removeAt(oldIndex);
                nextItems.insert(newIndex, item);
                onChange(nextItems);
              },
            ),
    );
  }
}

class MapInputPage extends StatelessWidget {
  final String title;
  final Map<String, String> map;
  final Widget Function(MapEntry<String, String> item) titleBuilder;
  final Widget Function(MapEntry<String, String> item)? subtitleBuilder;
  final Widget Function(MapEntry<String, String> item)? leadingBuilder;
  final String? keyLabel;
  final String? valueLabel;
  final Function(Map<String, String> items) onChange;
  final bool Function(MapEntry<String, String> item)? canDelete;

  const MapInputPage({
    super.key,
    required this.title,
    required this.map,
    required this.titleBuilder,
    required this.onChange,
    this.leadingBuilder,
    this.keyLabel,
    this.valueLabel,
    this.subtitleBuilder,
    this.canDelete,
  });

  List<MapEntry<String, String>> get items =>
      List<MapEntry<String, String>>.from(map.entries);

  Future<void> _handleAddOrEdit([MapEntry<String, String>? item]) async {
    uniqueValidator(String? value) {
      final index = items.indexWhere((entry) {
        return entry.key == value;
      });
      final current = item?.key == value;
      if (index != -1 && !current) {
        return appLocalizations.existsTip(appLocalizations.key);
      }
      return null;
    }

    final keyField = Field(
      label: keyLabel ?? appLocalizations.key,
      value: item == null ? '' : item.key,
      validator: uniqueValidator,
    );

    final valueField = Field(
      label: valueLabel ?? appLocalizations.value,
      value: item == null ? '' : item.value,
    );

    final value = await globalState.showCommonDialog<MapEntry<String, String>>(
      child: AddDialog(
        keyField: keyField,
        valueField: valueField,
        title: title,
      ),
    );
    if (value == null) return;
    final index = items.indexWhere((entry) {
      return entry.key == item?.key;
    });

    final nextItems = List<MapEntry<String, String>>.from(items);
    if (item != null) {
      nextItems[index] = value;
    } else {
      nextItems.add(value);
    }
    onChange(Map.fromEntries(nextItems));
  }

  void _handleDelete(MapEntry<String, String> item) {
    final entries = List<MapEntry<String, String>>.from(items);
    final index = entries.indexWhere((entry) {
      return entry.key == item.key && item.value == entry.value;
    });
    if (index != -1) {
      entries.removeAt(index);
    }
    onChange(Map.fromEntries(entries));
  }

  @override
  Widget build(BuildContext context) {
    return FloatLayout(
      floatingWidget: FloatWrapper(
        child: FloatingActionButton(
          onPressed: () async {
            _handleAddOrEdit();
          },
          child: const Icon(Icons.add),
        ),
      ),
      child: items.isEmpty
          ? NullStatus(label: appLocalizations.noData)
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 16 + 64),
              proxyDecorator: proxyDecorator,
              buildDefaultDragHandles: false,
              itemCount: items.length,
              itemBuilder: (_, index) {
                final e = items[index];
                return _InputItem(
                  key: ValueKey(e.key),
                  ReorderableDelayedDragStartListener(
                    index: index,
                    child: CommonCard(
                      child: ListItem(
                        leading: leadingBuilder != null
                            ? leadingBuilder!(e)
                            : null,
                        title: titleBuilder(e),
                        subtitle: subtitleBuilder != null
                            ? subtitleBuilder!(e)
                            : null,
                        trailing: (canDelete == null || canDelete!(e))
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  _handleDelete(e);
                                },
                              )
                            : null,
                      ),
                      onPressed: () {
                        _handleAddOrEdit(e);
                      },
                    ),
                  ),
                );
              },
              // ignore: deprecated_member_use
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final nextItems = List<MapEntry<String, String>>.from(items);
                final item = nextItems.removeAt(oldIndex);
                nextItems.insert(newIndex, item);
                onChange(Map.fromEntries(nextItems));
              },
            ),
    );
  }
}

class AddDialog extends StatefulWidget {
  final String title;
  final Field? keyField;
  final Field valueField;

  const AddDialog({
    super.key,
    required this.title,
    this.keyField,
    required this.valueField,
  });

  @override
  State<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController? keyController;
  late TextEditingController valueController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Field? get keyField => widget.keyField;

  Field get valueField => widget.valueField;

  @override
  void initState() {
    super.initState();
    if (keyField != null) {
      keyController = TextEditingController(text: keyField!.value);
    }
    valueController = TextEditingController(text: valueField.value);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (keyField != null) {
      Navigator.of(context).pop<MapEntry<String, String>>(
        MapEntry(keyController!.text, valueController.text),
      );
    } else {
      Navigator.of(context).pop<String>(valueController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonDialog(
      title: widget.title,
      actions: [
        TextButton(onPressed: _submit, child: Text(appLocalizations.confirm)),
      ],
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            if (keyField != null)
              TextFormField(
                maxLines: 2,
                minLines: 1,
                controller: keyController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: keyField!.label,
                ),
                validator: (String? value) {
                  String? res;
                  if (keyField!.validator != null) {
                    res = keyField!.validator!(value);
                  }
                  if (res != null) {
                    return res;
                  }
                  if (value == null || value.isEmpty) {
                    return appLocalizations.emptyTip(appLocalizations.key);
                  }
                  return null;
                },
              ),
            TextFormField(
              maxLines: 3,
              minLines: 1,
              controller: valueController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: valueField.label,
              ),
              validator: (String? value) {
                String? res;
                if (valueField.validator != null) {
                  res = valueField.validator!(value);
                }
                if (res != null) {
                  return res;
                }
                if (value == null || value.isEmpty) {
                  return appLocalizations.emptyTip(appLocalizations.value);
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InputItem extends StatelessWidget {
  final Widget child;

  const _InputItem(this.child, {super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      key: key,
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: child,
      ),
    );
  }
}
