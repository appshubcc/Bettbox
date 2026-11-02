import 'dart:math';

import 'package:bett_box/common/common.dart';
import 'package:bett_box/providers/app.dart';
import 'package:bett_box/widgets/pop_scope.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bett_box/state.dart';
import 'sheet.dart';
import 'text.dart';

class CommonDialog extends ConsumerWidget {
  final String title;
  final Widget? titleTrailing;
  final Widget? child;
  final List<Widget>? actions;
  final EdgeInsets? padding;
  final bool overrideScroll;
  final Color? backgroundColor;

  const CommonDialog({
    super.key,
    required this.title,
    this.titleTrailing,
    this.actions,
    this.child,
    this.padding,
    this.overrideScroll = false,
    this.backgroundColor,
  });

  List<Widget>? _buildActions(BuildContext context) {
    final actions = this.actions;
    if (actions == null || actions.isEmpty) {
      return actions;
    }
    final colorScheme = context.colorScheme;
    final backgroundColor = colorScheme.primary.opacity12;
    return [
      ...actions.take(actions.length - 1),
      FilledButtonTheme(
        data: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: colorScheme.primary,
            elevation: 0,
          ),
        ),
        child: TextButtonTheme(
          data: TextButtonThemeData(
            style: TextButton.styleFrom(
              backgroundColor: backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
          ),
          child: actions.last,
        ),
      ),
    ];
  }

  Widget _buildSheet(BuildContext context) {
    final actions = _buildActions(context);
    final inset = padding?.horizontal == 0 ? 0.0 : 16.0;
    final bottom = 16 + MediaQuery.paddingOf(context).bottom;
    final hasActions = actions != null && actions.isNotEmpty;
    final scrollBottom = hasActions || overrideScroll ? 8.0 : 8 + bottom;
    final content = DefaultTextStyle.merge(
      style: context.textTheme.bodyMedium?.copyWith(
        color: context.colorScheme.onSurfaceVariant,
      ),
      child: child ?? const SizedBox.shrink(),
    );
    return AdaptiveSheetScaffold(
      type: SheetType.bottomSheet,
      title: title,
      actions: [?titleTrailing],
      body: Padding(
        padding: EdgeInsets.only(
          bottom: hasActions || overrideScroll ? bottom : 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: overrideScroll
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: inset),
                      child: content,
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        inset,
                        0,
                        inset,
                        scrollBottom,
                      ),
                      child: content,
                    ),
            ),
            if (hasActions)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: OverflowBar(
                  alignment: MainAxisAlignment.end,
                  spacing: 8,
                  children: actions,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, ref) {
    if (isInBottomSheet(context)) return _buildSheet(context);
    final size = ref.watch(viewSizeProvider);
    final isMobileView = ref.watch(isMobileViewProvider);
    final isTv = globalState.isAndroidTV;
    final theme = Theme.of(context);
    return PopScope(
      canPop: !isTv,
      onPopInvokedWithResult: !isTv
          ? null
          : (didPop, result) {
              if (didPop) return;
              if (dismissTvInputFocus()) return;
              if (ModalRoute.of(context)?.isCurrent != true) return;
              Navigator.of(context).pop();
            },
      child: AlertDialog(
        alignment: isMobileView ? const Alignment(0, -0.12) : null,
        insetPadding: isMobileView
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 24)
            : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        title: titleTrailing == null
            ? EmojiText(title)
            : Row(
                children: [
                  Expanded(child: EmojiText(title)),
                  const SizedBox(width: 8),
                  ?titleTrailing,
                ],
              ),
        actions: _buildActions(context),
        titleTextStyle: context.textTheme.titleLarge?.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: padding ?? const EdgeInsets.fromLTRB(24, 12, 24, 20),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        backgroundColor: backgroundColor,
        content: Theme(
          data: theme.copyWith(
            inputDecorationTheme: theme.inputDecorationTheme.copyWith(
              fillColor: theme.brightness == Brightness.light
                  ? theme.colorScheme.surfaceContainer
                  : null,
            ),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: min(size.height - 40, 500),
              maxWidth: 300,
            ),
            width: size.width - 40,
            child: !overrideScroll
                ? SingleChildScrollView(child: child)
                : child,
          ),
        ),
      ),
    );
  }
}

class CommonModal extends ConsumerWidget {
  final Widget? child;

  const CommonModal({super.key, this.child});

  @override
  Widget build(BuildContext context, ref) {
    final size = ref.watch(viewSizeProvider);
    return Center(
      child: Container(
        width: size.width * 0.85,
        height: size.height * 0.85,
        decoration: ShapeDecoration(
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
