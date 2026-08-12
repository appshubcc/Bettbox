import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:re_highlight/re_highlight.dart';

/// This class provides both styling and functionality configuration for the scrollbar used in the [CodeForge].
/// Only vertical scrollbar can be tweaked using this class.
class ScrollbarDecoration {
  /// Whether to show the current line number near the scrollbar.
  /// Defaults to true
  final bool showLineNumberIndicator;

  /// The [TextStyle] style apllied on the line number indicator.
  /// Dosen't have any effect if [showLineNumberIndicator] set to false;
  final TextStyle? lineNumberStyle;

  /// {@template flutter.widgets.Scrollbar.thumbVisibility}
  /// Indicates that the scrollbar thumb should be visible, even when a scroll
  /// is not underway.
  ///
  /// When false, the scrollbar will be shown during scrolling
  /// and will fade out otherwise.
  ///
  /// When true, the scrollbar will always be visible and never fade out. This
  /// requires that the Scrollbar can access the [ScrollController] of the
  /// associated Scrollable widget. This can either be the provided [controller],
  /// or the [PrimaryScrollController] of the current context.
  ///
  ///   * When providing a controller, the same ScrollController must also be
  ///     provided to the associated Scrollable widget.
  ///   * The [PrimaryScrollController] is used by default for a [ScrollView]
  ///     that has not been provided a [ScrollController] and that has a
  ///     [ScrollView.scrollDirection] of [Axis.vertical]. This automatic
  ///     behavior does not apply to those with [Axis.horizontal]. To explicitly
  ///     use the PrimaryScrollController, set [ScrollView.primary] to true.
  ///
  /// Defaults to false when null.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// // (e.g. in a stateful widget)
  ///
  /// final ScrollController controllerOne = ScrollController();
  /// final ScrollController controllerTwo = ScrollController();
  ///
  /// @override
  /// Widget build(BuildContext context) {
  /// return Column(
  ///   children: <Widget>[
  ///     SizedBox(
  ///        height: 200,
  ///        child: Scrollbar(
  ///          thumbVisibility: true,
  ///          controller: controllerOne,
  ///          child: ListView.builder(
  ///            controller: controllerOne,
  ///            itemCount: 120,
  ///            itemBuilder: (BuildContext context, int index) {
  ///              return Text('item $index');
  ///            },
  ///          ),
  ///        ),
  ///      ),
  ///      SizedBox(
  ///        height: 200,
  ///        child: CupertinoScrollbar(
  ///          thumbVisibility: true,
  ///          controller: controllerTwo,
  ///          child: SingleChildScrollView(
  ///            controller: controllerTwo,
  ///            child: const SizedBox(
  ///              height: 2000,
  ///              width: 500,
  ///              child: Placeholder(),
  ///            ),
  ///          ),
  ///        ),
  ///      ),
  ///    ],
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///   * [RawScrollbarState.showScrollbar], an overridable getter which uses
  ///     this value to override the default behavior.
  ///   * [ScrollView.primary], which indicates whether the ScrollView is the primary
  ///     scroll view associated with the parent [PrimaryScrollController].
  ///   * [PrimaryScrollController], which associates a [ScrollController] with
  ///     a subtree.
  /// {@endtemplate}
  ///
  /// Subclass [Scrollbar] can hide and show the scrollbar thumb in response to
  /// [WidgetState]s by using [ScrollbarThemeData.thumbVisibility].
  final bool? thumbVisibility;

  /// The thickness of the scrollbar in the cross axis of the scrollable.
  ///
  /// If null, will default to 6.0 pixels.
  final double? thickness;

  /// The color of the scrollbar thumb.
  ///
  /// If null, defaults to Color(0x66BCBCBC).
  final Color? thumbColor;

  /// The preferred smallest size the scrollbar thumb can shrink to when the total
  /// scrollable extent is large, the current visible viewport is small, and the
  /// viewport is not overscrolled.
  ///
  /// The size of the scrollbar's thumb may shrink to a smaller size than [minThumbLength]
  /// to fit in the available paint area (e.g., when [minThumbLength] is greater
  /// than [ScrollMetrics.viewportDimension] and [mainAxisMargin] combined).
  ///
  /// Mustn't be null and the value has to be greater or equal to
  /// [minOverscrollLength], which in turn is >= 0. Defaults to 18.0.
  final double minThumbLength;

  /// The preferred smallest size the scrollbar thumb can shrink to when viewport is
  /// overscrolled.
  ///
  /// When overscrolling, the size of the scrollbar's thumb may shrink to a smaller size
  /// than [minOverscrollLength] to fit in the available paint area (e.g., when
  /// [minOverscrollLength] is greater than [ScrollMetrics.viewportDimension] and
  /// [mainAxisMargin] combined).
  ///
  /// Overscrolling can be made possible by setting the `physics` property
  /// of the `child` Widget to a `BouncingScrollPhysics`, which is a special
  /// `ScrollPhysics` that allows overscrolling.
  ///
  /// The value is less than or equal to [minThumbLength] and greater than or equal to 0.
  /// When null, it will default to the value of [minThumbLength].
  final double? minOverscrollLength;

  /// {@template flutter.widgets.Scrollbar.trackVisibility}
  /// Indicates that the scrollbar track should be visible.
  ///
  /// When true, the scrollbar track will always be visible so long as the thumb
  /// is visible. If the scrollbar thumb is not visible, the track will not be
  /// visible either.
  ///
  /// Defaults to false when null.
  /// {@endtemplate}
  ///
  /// Subclass [Scrollbar] can hide and show the scrollbar thumb in response to
  /// [WidgetState]s by using [ScrollbarThemeData.trackVisibility].
  final bool? trackVisibility;

  /// The [Radius] of the scrollbar track's rounded rectangle corners.
  ///
  /// Scrollbar's track will be rectangular if [trackRadius] is null, which is
  /// the default behavior.
  final Radius? trackRadius;

  /// The color of the scrollbar track.
  ///
  /// The scrollbar track will only be visible when [trackVisibility] and
  /// [thumbVisibility] are true.
  ///
  /// If null, defaults to Color(0x08000000).
  final Color? trackColor;

  /// The color of the scrollbar track's border.
  ///
  /// The scrollbar track will only be visible when [trackVisibility] and
  /// [thumbVisibility] are true.
  ///
  /// If null, defaults to Color(0x1a000000).
  final Color? trackBorderColor;

  /// The [Duration] of the fade animation.
  ///
  /// Defaults to a [Duration] of 300 milliseconds.
  final Duration fadeDuration;

  /// The [Duration] of time until the fade animation begins.
  ///
  /// Defaults to a [Duration] of 600 milliseconds.
  final Duration timeToFade;

  /// The [Duration] of time that a LongPress will trigger the drag gesture of
  /// the scrollbar thumb.
  ///
  /// Defaults to [Duration.zero].
  final Duration pressDuration;

  /// {@template flutter.widgets.Scrollbar.notificationPredicate}
  /// A check that specifies whether a [ScrollNotification] should be
  /// handled by this widget.
  ///
  /// By default, checks whether `notification.depth == 0`. That means if the
  /// scrollbar is wrapped around multiple [ScrollView]s, it only responds to the
  /// nearest scrollView and shows the corresponding scrollbar thumb.
  /// {@endtemplate}
  final ScrollNotificationPredicate notificationPredicate;

  /// {@template flutter.widgets.Scrollbar.interactive}
  /// Whether the Scrollbar should be interactive and respond to dragging on the
  /// thumb, or tapping in the track area.
  ///
  /// Does not apply to the [CupertinoScrollbar], which is always interactive to
  /// match native behavior. On Android, the scrollbar is not interactive by
  /// default.
  ///
  /// When false, the scrollbar will not respond to gesture or hover events,
  /// and will allow to click through it.
  ///
  /// Defaults to true when null, unless on Android, which will default to false
  /// when null.
  ///
  /// See also:
  ///
  ///   * [RawScrollbarState.enableGestures], an overridable getter which uses
  ///     this value to override the default behavior.
  /// {@endtemplate}
  final bool? interactive;

  /// {@macro flutter.widgets.Scrollbar.scrollbarOrientation}
  final ScrollbarOrientation? scrollbarOrientation;

  /// Distance from the scrollbar thumb's start or end to the nearest edge of
  /// the viewport in logical pixels. It affects the amount of available
  /// paint area.
  ///
  /// The scrollbar track consumes this space.
  ///
  /// Mustn't be null and defaults to 0.
  final double mainAxisMargin;

  /// Distance from the scrollbar thumb's side to the nearest cross axis edge
  /// in logical pixels.
  ///
  /// The scrollbar track consumes this space.
  ///
  /// Defaults to zero.
  final double crossAxisMargin;

  /// The insets by which the scrollbar thumb and track should be padded.
  ///
  /// When null, the inherited [MediaQueryData.padding] is used.
  ///
  /// Defaults to null.
  final EdgeInsetsGeometry? padding;

  final BorderRadius borderRadius;

  const ScrollbarDecoration({
    this.showLineNumberIndicator = true,
    this.lineNumberStyle,
    this.thumbColor,
    this.thickness,
    this.thumbVisibility,
    this.borderRadius = BorderRadius.zero,
    this.minThumbLength = 18.0,
    this.minOverscrollLength,
    this.trackVisibility,
    this.trackRadius,
    this.trackColor,
    this.trackBorderColor,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.timeToFade = const Duration(milliseconds: 600),
    this.pressDuration = Duration.zero,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.interactive,
    this.scrollbarOrientation,
    this.mainAxisMargin = 0.0,
    this.crossAxisMargin = 0.0,
    this.padding,
  });
}

/// This class provides styling options for code selection in the code editor.
class CodeSelectionStyle {
  /// The color of the cursor line, defaults to the highlight theme text color.
  final Color? cursorColor;

  /// The color used to highlight selected text in the code editor.
  final Color selectionColor;

  /// The color of the cursor bubble that appears when selecting text.
  final Color cursorBubbleColor;

  CodeSelectionStyle({
    this.cursorColor,
    this.selectionColor = const Color(0x6E2195F3),
    this.cursorBubbleColor = Colors.blue,
  });
}

/// This class provides styling options for the Gutter.
class GutterStyle {
  /// The style for line numbers in the gutter. Expected to be a [TextStyle].
  final TextStyle? lineNumberStyle;

  /// The background color of the gutter bar.
  final Color? backgroundColor;

  /// The color for the folded line folding indicator icon in the gutter. Defaults to [Colors.grey].
  final Color? foldedIconColor;

  /// The color for the unfolded line folding indicator icon in the gutter. Defaults to [Colors.grey].
  final Color? unfoldedIconColor;

  /// The width of the gutter. Dynamic by default, which means it can adapt best width based on line number. So recommended to leave it null.
  final double? gutterWidth;

  /// The size of the folding icon in the gutter. Defaults to (widget?.textStyle?.fontSize ?? 14) * 1.2.
  ///
  /// /// Recommended to leave it null, because the default value is dynamic based on editor fontSize.
  final double? foldingIconSize;

  /// The icon used for the folded line folding indicator in the gutter.
  ///
  /// Defaults to [Icons.chevron_right_outlined] for folded lines.
  final IconData unfoldedIcon;

  /// The icon used for the unfolded line folding indicator in the gutter.
  ///
  /// Defaults to [Icons.keyboard_arrow_down_outlined] for unfolded lines.
  final IconData foldedIcon;

  /// The color used to highlight the current line number in the gutter.
  /// If null, the line number will use the default text color.
  final Color? activeLineNumberColor;

  /// The color used for non-active line numbers in the gutter.
  /// If null, defaults to a dimmed version of the text color.
  final Color? inactiveLineNumberColor;

  /// The color used to highlight line numbers with errors (severity 1).
  /// Defaults to red.
  final Color errorLineNumberColor;

  /// The color used to highlight line numbers with warnings (severity 2).
  /// Defaults to yellow/orange.
  final Color warningLineNumberColor;

  /// The background color used to highlight folded line start.
  /// If null, a low opacity version of the selection color is used.
  final Color? foldedLineHighlightColor;

  GutterStyle({
    this.lineNumberStyle,
    this.backgroundColor,
    this.gutterWidth,
    this.foldedIcon = Icons.chevron_right_outlined,
    this.unfoldedIcon = Icons.keyboard_arrow_down_outlined,
    this.foldingIconSize,
    this.foldedIconColor,
    this.unfoldedIconColor,
    this.activeLineNumberColor,
    this.inactiveLineNumberColor,
    this.errorLineNumberColor = const Color(0xFFE53935),
    this.warningLineNumberColor = const Color(0xFFFFA726),
    this.foldedLineHighlightColor,
  });
}

/// Base class for overlay styling options used in various popup elements.
///
/// This sealed class provides common styling options for overlays such as
/// suggestion popups and hover details. Extend this class to create specific
/// overlay styles.
sealed class OverlayStyle {
  /// The elevation of the overlay, which determines the shadow depth.
  /// Defaults to 6.
  final double elevation;

  /// The background color of the overlay.
  final Color backgroundColor;

  /// The color used when the overlay is focused.
  final Color focusColor;

  /// The color used when the overlay is hovered.
  final Color hoverColor;

  /// The color used for the splash effect when the overlay is tapped.
  final Color splashColor;

  /// The shape of the overlay, which defines its border and corner radius.
  /// This can be a [ShapeBorder] such as [RoundedRectangleBorder], [CircleBorder], etc.
  final ShapeBorder shape;

  /// The text style used for the text in the overlay.
  /// This is typically a [TextStyle] that defines the font size, weight, color, etc.
  final TextStyle textStyle;
  OverlayStyle({
    this.elevation = 6,
    required this.shape,
    required this.backgroundColor,
    required this.focusColor,
    required this.hoverColor,
    required this.splashColor,
    required this.textStyle,
  });
}

/// Styling options for the code completion suggestion popup.
///
/// This class extends [OverlayStyle] to provide specific styling for the
/// autocomplete suggestion list that appears while typing in the editor.
/// Enhanced with VSCode-like styling options.
///
/// Example:
/// ```dart
/// SuggestionStyle(
///   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
///   backgroundColor: Color(0xFF252526), // VSCode dark theme background
///   selectedBackgroundColor: Color(0xFF094771), // VSCode selection color
///   focusColor: Color(0xff024281),
///   hoverColor: Color(0xFF2A2D2E), // VSCode hover color
///   splashColor: Colors.blueAccent.withAlpha(50),
///   borderColor: Color(0xFF454545), // VSCode border color
///   borderWidth: 1.0,
///   itemHeight: 24.0, // VSCode item height
///   iconSize: 16.0, // VSCode icon size
///   methodIconColor: Color(0xFFDCDFE4), // Light for methods
///   propertyIconColor: Color(0xFF98C379), // Green for properties
///   classIconColor: Color(0xFFE06C75), // Red for classes
///   variableIconColor: Color(0xFF61AFEF), // Blue for variables
///   keywordIconColor: Color(0xFFC678DD), // Purple for keywords
///   textStyle: TextStyle(color: Colors.white, fontSize: 13),
///   labelTextStyle: TextStyle(fontWeight: FontWeight.w500),
///   detailTextStyle: TextStyle(color: Colors.white70, fontSize: 11),
/// )
/// ```
class SuggestionStyle extends OverlayStyle {
  /// The background color for the selected item.
  final Color? selectedBackgroundColor;

  /// The border color for the suggestion popup.
  final Color? borderColor;

  /// The border width for the suggestion popup.
  final double? borderWidth;

  /// The height of each suggestion item.
  final double? itemHeight;

  /// The size of icons in the suggestion list.
  final double? iconSize;

  /// The color for method/function icons.
  final Color? methodIconColor;

  /// The color for property/field icons.
  final Color? propertyIconColor;

  /// The color for class/type icons.
  final Color? classIconColor;

  /// The color for variable icons.
  final Color? variableIconColor;

  /// The color for keyword icons.
  final Color? keywordIconColor;

  /// The text style for the suggestion label.
  final TextStyle? labelTextStyle;

  /// The text style for additional information (like import paths).
  final TextStyle? detailTextStyle;

  /// The text style for type information.
  final TextStyle? typeTextStyle;

  /// Creates a [SuggestionStyle] with the specified options.
  SuggestionStyle({
    super.elevation,
    required super.shape,
    required super.backgroundColor,
    required super.focusColor,
    required super.hoverColor,
    required super.splashColor,
    required super.textStyle,
    this.selectedBackgroundColor,
    this.borderColor,
    this.borderWidth,
    this.itemHeight,
    this.iconSize,
    this.methodIconColor,
    this.propertyIconColor,
    this.classIconColor,
    this.variableIconColor,
    this.keywordIconColor,
    this.labelTextStyle,
    this.detailTextStyle,
    this.typeTextStyle,
  });
}

/// Styling options for the hover details popup.
///
/// This class extends [OverlayStyle] to provide specific styling for the
/// popup that shows documentation or type information when hovering over
/// code elements (requires LSP integration).
///
/// Example:
/// ```dart
/// HoverDetailsStyle(
///   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
///   backgroundColor: Colors.grey[850]!,
///   focusColor: Colors.blue.withOpacity(0.3),
///   hoverColor: Colors.blue.withOpacity(0.1),
///   splashColor: Colors.blue.withOpacity(0.2),
///   textStyle: TextStyle(color: Colors.white),
/// )
/// ```
class HoverDetailsStyle extends OverlayStyle {
  /// Creates a [HoverDetailsStyle] with the specified options.
  HoverDetailsStyle({
    super.elevation,
    required super.shape,
    required super.backgroundColor,
    required super.focusColor,
    required super.hoverColor,
    required super.splashColor,
    required super.textStyle,
  });
}

/// Represents a highlighted search result in the editor
class SearchHighlight {
  /// The start offset of the highlighted text
  final int start;

  /// The end offset of the highlighted text
  final int end;

  /// Whether this highlight represents the currently selected match
  final bool isCurrentMatch;

  const SearchHighlight({
    required this.start,
    required this.end,
    this.isCurrentMatch = false,
  });
}

/// Styles used to highlight occurrences found by the controller.findWord() API.
///
/// Provides separate TextStyle values for the currently selected match and for
/// all other matches, so the active match can be visually emphasized while
/// keeping other matches visible.
///
/// Fields:
/// - currentMatchStyle: TextStyle applied to the currently selected/active
///   match. Use this to draw attention to the match the user is navigating to.
/// - otherMatchStyle: TextStyle applied to all non-active matches. Typically
///   a subtler style than the currentMatchStyle (for example a translucent
///   background color).
///
/// Usage example:
/// ```dart
/// matchHighlightStyle: const MatchHighlightStyle(
///   currentMatchStyle: TextStyle(
///     backgroundColor: Color(0xFFFFA726),
///   ),
///   otherMatchStyle: TextStyle(
///     backgroundColor: Color(0x55FFFF00),
///   ),
/// ),
/// ```
///
/// Notes:
/// - Prefer using const constructors and const TextStyle values where possible
///   to improve performance.
/// - The exact visual result depends on how the editor widget composes the
///   TextStyle with surrounding styles; typically only the differing properties
///   (for example backgroundColor) will have a visible effect.
class MatchHighlightStyle {
  /// Style for the currently selected match.
  final TextStyle currentMatchStyle;

  /// Style for all other matches.
  final TextStyle otherMatchStyle;

  const MatchHighlightStyle({
    required this.currentMatchStyle,
    required this.otherMatchStyle,
  });
}

/// Defines decoration types for line decorations in the editor.
///
/// Used to specify how a line range should be visually decorated,
/// such as for git diff highlighting, bookmarks, or custom markers.
enum LineDecorationType {
  /// Full line background highlight
  background,

  /// Left border/bar indicator (like git diff added/removed)
  leftBorder,

  /// Underline decoration
  underline,

  /// Wavy underline (like error indicators)
  wavyUnderline,
}

/// Represents a decoration applied to a range of lines in the editor.
///
/// Line decorations can be used to highlight code changes (git diff),
/// mark breakpoints, show coverage information, or any custom highlighting.
///
/// Example - Git diff added lines:
/// ```dart
/// controller.addLineDecoration(LineDecoration(
///   startLine: 10,
///   endLine: 15,
///   type: LineDecorationType.background,
///   color: Colors.green.withOpacity(0.2),
/// ));
/// ```
///
/// Example - Git diff left border:
/// ```dart
/// controller.addLineDecoration(LineDecoration(
///   startLine: 10,
///   endLine: 15,
///   type: LineDecorationType.leftBorder,
///   color: Colors.green,
///   thickness: 3,
/// ));
/// ```
class LineDecoration {
  /// Unique identifier for this decoration
  final String id;

  /// The start line (0-based) of the decoration range
  final int startLine;

  /// The end line (0-based, inclusive) of the decoration range
  final int endLine;

  /// The type of decoration to apply
  final LineDecorationType type;

  /// The color of the decoration
  final Color color;

  /// Thickness for border/underline decorations (default: 3.0)
  final double thickness;

  /// Optional priority for overlapping decorations (higher = on top)
  final int priority;

  /// Creates a line decoration.
  ///
  /// [id] - Unique identifier for managing the decoration
  /// [startLine] - First line to decorate (0-based)
  /// [endLine] - Last line to decorate (0-based, inclusive)
  /// [type] - The decoration style to apply
  /// [color] - Color of the decoration
  /// [thickness] - Width for border/underline decorations
  /// [priority] - Z-order for overlapping decorations
  const LineDecoration({
    required this.id,
    required this.startLine,
    required this.endLine,
    required this.type,
    required this.color,
    this.thickness = 3.0,
    this.priority = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineDecoration &&
          id == other.id &&
          startLine == other.startLine &&
          endLine == other.endLine;

  @override
  int get hashCode => Object.hash(id, startLine, endLine);
}

/// Defines decoration types for gutter decorations.
enum GutterDecorationType {
  /// Colored bar/stripe in the gutter
  colorBar,

  /// Custom icon in the gutter
  icon,

  /// Dot/circle indicator
  dot,
}

/// Represents a decoration in the gutter area (line numbers column).
///
/// Gutter decorations are useful for showing git diff status,
/// breakpoints, bookmarks, or other line-level indicators.
///
/// Example - Git diff added indicator:
/// ```dart
/// controller.addGutterDecoration(GutterDecoration(
///   startLine: 10,
///   endLine: 15,
///   type: GutterDecorationType.colorBar,
///   color: Colors.green,
/// ));
/// ```
///
/// Example - Breakpoint icon:
/// ```dart
/// controller.addGutterDecoration(GutterDecoration(
///   startLine: 25,
///   endLine: 25,
///   type: GutterDecorationType.icon,
///   color: Colors.red,
///   icon: Icons.circle,
/// ));
/// ```
class GutterDecoration {
  /// Unique identifier for this decoration
  final String id;

  /// The start line (0-based) of the decoration range
  final int startLine;

  /// The end line (0-based, inclusive) of the decoration range
  final int endLine;

  /// The type of gutter decoration
  final GutterDecorationType type;

  /// The color of the decoration
  final Color color;

  /// Icon to display (only used when type is [GutterDecorationType.icon])
  final IconData? icon;

  /// Width of the color bar (default: 3.0)
  final double width;

  /// Optional tooltip text shown on hover
  final String? tooltip;

  /// Optional priority for overlapping decorations (higher = on top)
  final int priority;

  /// Creates a gutter decoration.
  const GutterDecoration({
    required this.id,
    required this.startLine,
    required this.endLine,
    required this.type,
    required this.color,
    this.icon,
    this.width = 3.0,
    this.tooltip,
    this.priority = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GutterDecoration &&
          id == other.id &&
          startLine == other.startLine &&
          endLine == other.endLine;

  @override
  int get hashCode => Object.hash(id, startLine, endLine);
}

/// Represents ghost text (inline suggestion) displayed in the editor.
///
/// Ghost text appears as semi-transparent text at the cursor position,
/// typically used for AI code completion suggestions.
///
/// When [shouldPersist] is false (default), the ghost text will be:
/// - Cleared when the cursor moves or text changes don't match
/// - Accepted (inserted) when Tab or Right Arrow is pressed
///
/// When [shouldPersist] is true, the ghost text will only be cleared
/// by explicitly calling [CodeForgeController.clearGhostText].
///
/// Example:
/// ```dart
/// controller.setGhostText(GhostText(
///   line: 10,
///   column: 15,
///   text: 'print("Hello, World!");',
///   style: TextStyle(
///     color: Colors.grey.withOpacity(0.5),
///     fontStyle: FontStyle.italic,
///   ),
/// ));
/// ```
class GhostText {
  /// The line where the ghost text starts (0-based)
  final int line;

  /// The column where the ghost text starts (0-based)
  final int column;

  /// The ghost text content (can be multi-line with \n)
  final String text;

  /// Text style for the ghost text
  final TextStyle? style;

  /// Whether the ghost text should persist until explicitly cleared.
  ///
  /// When false (default), the ghost text will be cleared on cursor
  /// movement or mismatched typing, and accepted on Tab/Right Arrow.
  /// When true, the ghost text can only be cleared by calling
  /// [CodeForgeController.clearGhostText].
  final bool shouldPersist;

  /// Creates a ghost text decoration.
  ///
  /// [line] - The line number where text appears (0-based)
  /// [column] - The column position where text starts (0-based)
  /// [text] - The suggestion text to display
  /// [style] - Optional custom style (defaults to semi-transparent italic)
  /// [shouldPersist] - If true, only cleared by clearGhostText(); if false,
  ///   cleared on cursor movement and accepted on Tab/Right Arrow
  const GhostText({
    required this.line,
    required this.column,
    required this.text,
    this.style,
    this.shouldPersist = false,
  });
}

/// An in-progress IME composition (e.g. CJK pinyin/kana), rendered as a
/// transient overlay above the document rather than written into it.
///
/// While a composition is active the editor's document (rope) is left
/// untouched; the composing text lives only in an instance of this class and
/// is painted at [anchor]. The committed result is written to the document as
/// a single edit only when the platform input method finalizes the
/// composition. This keeps the document free of transient composing glyphs
/// and lets the editor render the composing string itself. [displayText]
/// preserves the platform composing string for display (for example `hao'jia`),
/// while [commitText] stores the user's typed intent for interruption commits.
@immutable
class ImeComposition {
  /// Global document offset where composition starts.
  final int anchor;

  /// The text displayed in the IME overlay (exactly as reported by the platform).
  /// This includes any input method decorators like pinyin separators (a'a'a'a).
  final String displayText;

  /// Local caret position within [displayText].
  final int displayCaret;

  /// The intended text to be committed if the composition is interrupted.
  /// This is determined by the Incremental Intent Tracking algorithm to
  /// distinguish between user-typed characters and IME-auto-generated characters.
  final String commitText;

  const ImeComposition({
    required this.anchor,
    required this.displayText,
    required this.displayCaret,
    required this.commitText,
  });

  /// Whether there is no composing text (an inactive composition).
  bool get isEmpty => displayText.isEmpty;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImeComposition &&
          other.anchor == anchor &&
          other.displayText == displayText &&
          other.displayCaret == displayCaret &&
          other.commitText == commitText;

  @override
  int get hashCode =>
      Object.hash(anchor, displayText, displayCaret, commitText);
}

/// Represents a block of removed lines to be displayed virtually in the editor.
///
/// Virtual removed lines appear between real document lines, showing
/// content that was deleted (e.g., in a git diff). They are rendered
/// without line numbers and are read-only, similar to ghost text.
///
/// Example:
/// ```dart
/// VirtualRemovedBlock(
///   afterLine: 29,
///   content: 'final x = 10;\nfinal y = 20;',
///   backgroundColor: Color(0x30E53935),
/// )
/// ```
class VirtualRemovedBlock {
  /// The line in the current file after which the removed content appears (0-based).
  final int afterLine;

  /// The removed text content. Lines are separated by `\n`.
  final String content;

  /// Background color for the removed lines area.
  final Color backgroundColor;

  /// Text style for the removed content.
  final TextStyle? textStyle;

  /// Creates a virtual removed block.
  ///
  /// [afterLine] - The 0-based line number after which to display the removed content.
  /// [content] - The deleted text content (use `\n` for multiple lines).
  /// [backgroundColor] - Background fill color for the removed area.
  /// [textStyle] - Optional custom text style for the removed text.
  const VirtualRemovedBlock({
    required this.afterLine,
    required this.content,
    this.backgroundColor = const Color(0x30E53935),
    this.textStyle,
  });

  /// Number of lines in this removed block.
  int get lineCount => content.split('\n').length;

  /// Individual lines of the removed content.
  List<String> get lines => content.split('\n');
}

/// Represents an inlay hint to be displayed inline in the code editor.
///
/// Inlay hints are small pieces of text displayed inline with the code,
/// typically showing type annotations, parameter names, or other contextual
/// information from the language server.
///
/// Example:
/// ```dart
/// InlayHint(
///   line: 10,
///   column: 15,
///   text: 'String',
///   kind: InlayHintKind.type,
/// )
/// ```
class InlayHint {
  /// The line where the inlay hint should appear (0-based)
  final int line;

  /// The column (character position) where the inlay hint should appear (0-based)
  final int column;

  /// The text content of the inlay hint
  final String text;

  /// The kind of inlay hint (type annotation or parameter name)
  final InlayHintKind kind;

  /// Whether to add padding to the right of the hint
  final bool paddingRight;

  /// Whether to add padding to the left of the hint
  final bool paddingLeft;

  /// Optional location information for navigation
  final Map<String, dynamic>? location;

  const InlayHint({
    required this.line,
    required this.column,
    required this.text,
    required this.kind,
    this.paddingRight = false,
    this.paddingLeft = false,
    this.location,
  });

  /// Creates an InlayHint from LSP response data
  factory InlayHint.fromLsp(Map<String, dynamic> data) {
    final position = data['position'] as Map<String, dynamic>;
    final kind = data['kind'] as int? ?? 1;
    final label = data['label'];
    final paddingRight = data['paddingRight'] as bool? ?? false;
    final paddingLeft = data['paddingLeft'] as bool? ?? false;

    String text;
    Map<String, dynamic>? location;

    if (label is List && label.isNotEmpty) {
      final parts = <String>[];
      for (final part in label) {
        if (part is Map<String, dynamic>) {
          parts.add(part['value'] as String? ?? '');
          if (part.containsKey('location')) {
            location = part['location'] as Map<String, dynamic>?;
          }
        } else if (part is String) {
          parts.add(part);
        }
      }
      text = parts.join();
    } else if (label is String) {
      text = label;
    } else {
      text = '';
    }

    return InlayHint(
      line: position['line'] as int,
      column: position['character'] as int,
      text: text,
      kind: kind == 1 ? InlayHintKind.type : InlayHintKind.parameter,
      paddingRight: paddingRight,
      paddingLeft: paddingLeft,
      location: location,
    );
  }
}

/// The kind of inlay hint
enum InlayHintKind {
  /// Type annotation hint (kind: 1 in LSP)
  type,

  /// Parameter name hint (kind: 2 in LSP)
  parameter,
}

/// Represents a document color to be displayed in the code editor.
///
/// Document colors show a small color box inline with color literals,
/// allowing users to visualize the color directly in the code.
///
/// Example:
/// ```dart
/// DocumentColor(
///   line: 10,
///   startColumn: 15,
///   endColumn: 25,
///   color: Color(0xFFFF0000),
/// )
/// ```
class DocumentColor {
  /// The line where the color appears (0-based)
  final int line;

  /// The start column of the color range (0-based)
  final int startColumn;

  /// The end column of the color range (0-based)
  final int endColumn;

  /// The actual color value
  final Color color;

  const DocumentColor({
    required this.line,
    required this.startColumn,
    required this.endColumn,
    required this.color,
  });

  /// Creates a DocumentColor from LSP response data
  factory DocumentColor.fromLsp(Map<String, dynamic> data) {
    final range = data['range'] as Map<String, dynamic>;
    final start = range['start'] as Map<String, dynamic>;
    final end = range['end'] as Map<String, dynamic>;
    final colorData = data['color'] as Map<String, dynamic>;

    final red = (colorData['red'] as num).toDouble();
    final green = (colorData['green'] as num).toDouble();
    final blue = (colorData['blue'] as num).toDouble();
    final alpha = (colorData['alpha'] as num).toDouble();

    return DocumentColor(
      line: start['line'] as int,
      startColumn: start['character'] as int,
      endColumn: end['character'] as int,
      color: Color.fromARGB(
        (alpha * 255).round(),
        (red * 255).round(),
        (green * 255).round(),
        (blue * 255).round(),
      ),
    );
  }
}

/// Represents a document highlight from LSP.
/// Used to highlight all occurrences of a symbol in the document.
class DocumentHighlight {
  /// The start line of the highlight (0-based)
  final int startLine;

  /// The start column of the highlight (0-based)
  final int startColumn;

  /// The end line of the highlight (0-based)
  final int endLine;

  /// The end column of the highlight (0-based)
  final int endColumn;

  const DocumentHighlight({
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
  });

  /// Creates a DocumentHighlight from LSP response data
  factory DocumentHighlight.fromLsp(Map<String, dynamic> data) {
    final range = data['range'] as Map<String, dynamic>;
    final start = range['start'] as Map<String, dynamic>;
    final end = range['end'] as Map<String, dynamic>;

    return DocumentHighlight(
      startLine: start['line'] as int,
      startColumn: start['character'] as int,
      endLine: end['line'] as int,
      endColumn: end['character'] as int,
    );
  }
}

class CustomTheme {
  ///Create a custom theme for code_forge instead of using prebuilt ones from the re_highlight package.
  static Map<String, TextStyle> create({
    required Color color,
    required Color backgroundColor,
    TextStyle? keyword,
    TextStyle? operator,
    TextStyle? function,
    TextStyle? funtionParams,
    TextStyle? funtionParamsTyping,
    TextStyle? comment,
    TextStyle? quote,
    TextStyle? constructorString,
    TextStyle? doctag,
    TextStyle? formula,
    TextStyle? section,
    TextStyle? name,
    TextStyle? selectorTag,
    TextStyle? deletion,
    TextStyle? literal,
    TextStyle? string,
    TextStyle? regexp,
    TextStyle? attribute,
    TextStyle? addition,
    TextStyle? metaString,
    TextStyle? builtIn,
    TextStyle? variable,
    TextStyle? patternMatch,
    TextStyle? patternMatchConstructor,
    TextStyle? moduleAccessModule,
    TextStyle? subst,
    TextStyle? titleClass,
    TextStyle? classTitle,
    TextStyle? attr,
    TextStyle? templateVariable,
    TextStyle? type,
    TextStyle? selectorClass,
    TextStyle? selectorAttr,
    TextStyle? selectorPseudo,
    TextStyle? number,
    TextStyle? symbol,
    TextStyle? bullet,
    TextStyle? link,
    TextStyle? meta,
    TextStyle? selectorId,
    TextStyle? title,
  }) {
    return {
      'root': TextStyle(color: color, backgroundColor: backgroundColor),
      'keyword': keyword ?? TextStyle(color: keyword?.color),
      'operator': operator ?? TextStyle(color: operator?.color),
      'pattern-match': patternMatch ?? TextStyle(color: patternMatch?.color),
      'pattern-match-constructor':
          patternMatchConstructor ??
          TextStyle(color: patternMatchConstructor?.color),
      'function': function ?? TextStyle(color: function?.color),
      'function-params':
          funtionParams ?? TextStyle(color: funtionParams?.color),
      'function-params-typing':
          funtionParamsTyping ?? TextStyle(color: funtionParamsTyping?.color),
      'module-access-module':
          moduleAccessModule ?? TextStyle(color: moduleAccessModule?.color),
      'constructor-string':
          constructorString ?? TextStyle(color: constructorString?.color),
      'comment':
          comment ??
          TextStyle(color: comment?.color, fontStyle: FontStyle.italic),
      'quote':
          quote ?? TextStyle(color: quote?.color, fontStyle: FontStyle.italic),
      'doctag': doctag ?? TextStyle(color: doctag?.color),
      'formula': formula ?? TextStyle(color: formula?.color),
      'section': section ?? TextStyle(color: section?.color),
      'name': name ?? TextStyle(color: name?.color),
      'selector-tag': selectorTag ?? TextStyle(color: selectorTag?.color),
      'deletion': deletion ?? TextStyle(color: deletion?.color),
      'subst': subst ?? TextStyle(color: subst?.color),
      'literal': literal ?? TextStyle(color: literal?.color),
      'string': string ?? TextStyle(color: string?.color),
      'regexp': regexp ?? TextStyle(color: regexp?.color),
      'addition': addition ?? TextStyle(color: addition?.color),
      'attribute': attribute ?? TextStyle(color: attribute?.color),
      'meta-string': metaString ?? TextStyle(color: metaString?.color),
      'built_in': builtIn ?? TextStyle(color: builtIn?.color),
      'title.class_': titleClass ?? TextStyle(color: titleClass?.color),
      'class-title': classTitle ?? TextStyle(color: classTitle?.color),
      'attr': attr ?? TextStyle(color: attr?.color),
      'variable': variable ?? TextStyle(color: variable?.color),
      'template-variable':
          templateVariable ?? TextStyle(color: templateVariable?.color),
      'type': type ?? TextStyle(color: type?.color),
      'selector-class': selectorClass ?? TextStyle(color: selectorClass?.color),
      'selector-attr': selectorAttr ?? TextStyle(color: selectorAttr?.color),
      'selector-pseudo':
          selectorPseudo ?? TextStyle(color: selectorPseudo?.color),
      'number': number ?? TextStyle(color: number?.color),
      'symbol': symbol ?? TextStyle(color: symbol?.color),
      'bullet': bullet ?? TextStyle(color: bullet?.color),
      'link': link ?? TextStyle(color: link?.color),
      'meta': meta ?? TextStyle(color: meta?.color),
      'selector-id': selectorId ?? TextStyle(color: selectorId?.color),
      'title': title ?? TextStyle(color: title?.color),
      'emphasis': TextStyle(fontStyle: FontStyle.italic),
      'strong': TextStyle(fontWeight: FontWeight.bold),
    };
  }
}

class CustomLanguageGrammar {
  /// Converts a TextMate grammar JSON string into a re_highlight [Mode].
  ///
  /// TextMate grammars use scope names (e.g. `keyword.control.dart`,
  /// `string.quoted.double`) which must be mapped to highlight.js class names
  /// (`keyword`, `string`, `comment`, `number`, etc.) that re_highlight themes
  /// understand.
  static Mode fromJson(String json) {
    final decoded = jsonDecode(json) as Map<String, dynamic>;

    final repository = <String, dynamic>{};
    if (decoded.containsKey('repository')) {
      final repo = decoded['repository'] as Map<String, dynamic>;
      repo.forEach((key, value) {
        repository[key] = value;
      });
    }

    final keywordSets = <String, Set<String>>{};
    _collectKeywords(repository, keywordSets);

    final root = Mode(
      name: decoded['name'] as String?,
      aliases: decoded.containsKey('aliases')
          ? (decoded['aliases'] as List).cast<String>()
          : null,
    );

    if (keywordSets.isNotEmpty) {
      final keywordsMap = <String, dynamic>{};
      keywordsMap['\$pattern'] = r'[A-Za-z_]\w*|__\w+__';
      keywordSets.forEach((category, words) {
        keywordsMap[category] = words.toList();
      });
      root.keywords = keywordsMap;
    }

    final contains = <Mode>[];
    _buildStandardContains(repository, contains);
    root.contains = contains.isNotEmpty ? contains : null;

    return root;
  }

  static void _buildStandardContains(
    Map<String, dynamic> repository,
    List<Mode> contains,
  ) {
    final hasHashComments =
        repository.containsKey('comments') ||
        repository.containsKey('comments-base') ||
        repository.containsKey('comment');
    final hasSlashComments = _repoContainsBegin(repository, '//');
    final hasBlockComments = _repoContainsBegin(repository, r'/\*');

    if (hasHashComments) {
      contains.add(Mode(scope: 'comment', begin: '#', end: r'$'));
    }
    if (hasSlashComments) {
      contains.add(Mode(scope: 'comment', begin: '//', end: r'$'));
    }
    if (hasBlockComments) {
      contains.add(Mode(scope: 'comment', begin: r'/\*', end: r'\*/'));
    }

    final hasTripleQuote =
        _repoContainsScope(repository, 'string.quoted.multi') ||
        _repoContainsScope(repository, 'string.quoted.docstring.multi') ||
        repository.containsKey('docstring');
    final hasSingleQuote =
        _repoContainsScope(repository, 'string.quoted.single') ||
        _repoContainsScope(repository, 'string.quoted') ||
        repository.containsKey('string-quoted-single-line');
    final hasDoubleQuote =
        _repoContainsScope(repository, 'string.quoted') ||
        repository.containsKey('string-quoted-single-line');

    if (hasTripleQuote) {
      contains.add(
        Mode(scope: 'string', begin: "'''", end: "'''", relevance: 10),
      );
      contains.add(
        Mode(scope: 'string', begin: '"""', end: '"""', relevance: 10),
      );
    }

    if (hasSingleQuote || hasDoubleQuote) {
      contains.add(
        Mode(
          scope: 'string',
          begin: "'",
          end: "'",
          contains: [Mode(match: r"\\.")],
        ),
      );
      contains.add(
        Mode(
          scope: 'string',
          begin: '"',
          end: '"',
          contains: [Mode(match: r"\\.")],
        ),
      );
    }

    final hasNumbers =
        repository.containsKey('number-float') ||
        repository.containsKey('number-dec') ||
        repository.containsKey('number') ||
        _repoContainsScope(repository, 'constant.numeric');
    if (hasNumbers) {
      contains.add(
        Mode(scope: 'number', match: r'(?<![.\w])0[Xx][\da-fA-F_]+\b'),
      );
      contains.add(Mode(scope: 'number', match: r'(?<![.\w])0[Oo][0-7_]+\b'));
      contains.add(Mode(scope: 'number', match: r'(?<![.\w])0[Bb][01_]+\b'));
      contains.add(
        Mode(
          scope: 'number',
          match: r'(?<!\w)(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?[jJ]?\b',
        ),
      );
    }

    if (repository.containsKey('function-declaration') ||
        repository.containsKey('function-definition') ||
        _repoContainsScope(repository, 'entity.name.function')) {
      contains.add(
        Mode(
          match: [r'\b(def|func|function|fn)', r'\s+', r'(\w+)'],
          scope: <int, String>{1: 'keyword', 3: 'title.function'},
        ),
      );
    }

    if (repository.containsKey('class-declaration') ||
        repository.containsKey('class-definition') ||
        _repoContainsScope(repository, 'entity.name.class') ||
        _repoContainsScope(repository, 'entity.name.type.class')) {
      contains.add(
        Mode(
          match: [r'\b(class)', r'\s+', r'(\w+)'],
          scope: <int, String>{1: 'keyword', 3: 'title.class'},
        ),
      );
    }

    if (repository.containsKey('decorator')) {
      contains.add(Mode(scope: 'meta', match: r'@\w+'));
    }

    if (repository.containsKey('ellipsis')) {
      contains.add(Mode(scope: 'literal', match: r'\.\.\.'));
    }

    _addSafePatterns(repository, contains);
  }

  static void _addSafePatterns(
    Map<String, dynamic> repository,
    List<Mode> contains,
  ) {
    final added = <String>{};

    repository.forEach((key, entry) {
      if (entry is! Map<String, dynamic>) return;

      final items = <Map<String, dynamic>>[
        entry,
        if (entry.containsKey('patterns'))
          ...(entry['patterns'] as List).whereType<Map<String, dynamic>>(),
      ];

      for (final p in items) {
        final name = p['name'] as String? ?? p['contentName'] as String? ?? '';
        if (name.isEmpty) continue;

        final className = _mapScopeToClassName(name);
        if (className == null) continue;

        if (className != 'number') continue;

        if (p.containsKey('match')) {
          final regex = _sanitizeRegex(p['match'] as String);
          if (_isValidRegex(regex) &&
              !_isOverlyBroad(regex) &&
              !_hasPosixClass(regex) &&
              !added.contains(regex)) {
            added.add(regex);
            contains.add(Mode(match: regex, scope: className));
          }
        }
      }
    });
  }

  static bool _repoContainsBegin(
    Map<String, dynamic> repository,
    String begin,
  ) {
    for (final entry in repository.values) {
      if (entry is! Map<String, dynamic>) continue;
      if ((entry['begin'] as String? ?? '').contains(begin)) return true;
      if (entry.containsKey('patterns')) {
        for (final p in entry['patterns'] as List) {
          if (p is Map<String, dynamic> &&
              (p['begin'] as String? ?? '').contains(begin)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  static bool _repoContainsScope(
    Map<String, dynamic> repository,
    String scopePrefix,
  ) {
    for (final entry in repository.values) {
      if (entry is! Map<String, dynamic>) continue;
      final name = entry['name'] as String? ?? '';
      if (name.startsWith(scopePrefix)) return true;
      if (entry.containsKey('patterns')) {
        for (final p in entry['patterns'] as List) {
          if (p is Map<String, dynamic>) {
            final pName = p['name'] as String? ?? '';
            if (pName.startsWith(scopePrefix)) return true;
          }
        }
      }
    }
    return false;
  }

  static bool _isOverlyBroad(String regex) {
    if (RegExp(r'^\(?\.[\+\*]').hasMatch(regex)) return true;
    if (regex.startsWith('(.+?)')) return true;
    return false;
  }

  static bool _hasPosixClass(String regex) {
    return regex.contains('[:alpha:]') ||
        regex.contains('[:upper:]') ||
        regex.contains('[:lower:]') ||
        regex.contains('[:digit:]') ||
        regex.contains('[:alnum:]') ||
        regex.contains(r'\p{') ||
        regex.contains(r'\P{');
  }

  static String? _mapScopeToClassName(String tmScope) {
    final parts = tmScope.split('.');
    if (parts.isEmpty) return null;

    final base = parts[0];
    switch (base) {
      case 'keyword':
        return 'keyword';
      case 'comment':
        return 'comment';
      case 'string':
        return 'string';
      case 'constant':
        if (parts.length > 1) {
          switch (parts[1]) {
            case 'numeric':
              return 'number';
            case 'language':
              return 'literal';
            case 'character':
              return 'string';
            default:
              return 'literal';
          }
        }
        return 'literal';
      case 'variable':
        if (parts.length > 1 && parts[1] == 'language') {
          return 'variable.language';
        }
        return 'variable';
      case 'entity':
        if (parts.length > 1) {
          switch (parts[1]) {
            case 'name':
              if (parts.length > 2) {
                switch (parts[2]) {
                  case 'function':
                    return 'title.function';
                  case 'type':
                  case 'class':
                    return 'title.class';
                  case 'tag':
                    return 'selector-tag';
                  case 'section':
                    return 'section';
                  default:
                    return 'title';
                }
              }
              return 'title';
            case 'other':
              return 'attr';
            default:
              return 'title';
          }
        }
        return 'title';
      case 'support':
        if (parts.length > 1) {
          switch (parts[1]) {
            case 'function':
              return 'built_in';
            case 'class':
            case 'type':
              return 'built_in';
            case 'constant':
              return 'literal';
            case 'variable':
              return 'variable';
            default:
              return 'built_in';
          }
        }
        return 'built_in';
      case 'storage':
        if (parts.length > 1 && parts[1] == 'type') {
          return 'type';
        }
        return 'keyword';
      case 'meta':
        if (parts.length > 1 && parts[1] == 'embedded') {
          return 'subst';
        }
        return 'meta';
      case 'punctuation':
        return 'punctuation';
      case 'invalid':
        return 'comment';
      case 'markup':
        if (parts.length > 1) {
          switch (parts[1]) {
            case 'bold':
              return 'strong';
            case 'italic':
              return 'emphasis';
            case 'underline':
              return 'link';
            default:
              return null;
          }
        }
        return null;
      default:
        return null;
    }
  }

  static void _collectKeywords(
    Map<String, dynamic> repository,
    Map<String, Set<String>> keywordSets,
  ) {
    void visitEntry(dynamic entry, Set<String> visited) {
      if (entry is! Map<String, dynamic>) return;

      if (entry.containsKey('patterns')) {
        final patterns = entry['patterns'] as List<dynamic>;
        for (final p in patterns) {
          if (p is! Map<String, dynamic>) continue;

          if (p.containsKey('include')) {
            final include = p['include'] as String;
            if (include.startsWith('#')) {
              final ref = include.substring(1);
              if (!visited.contains(ref) && repository.containsKey(ref)) {
                final newVisited = Set<String>.from(visited)..add(ref);
                visitEntry(repository[ref], newVisited);
              }
            }
            continue;
          }

          if (p.containsKey('match') && p.containsKey('name')) {
            _tryExtractKeywords(
              p['match'] as String,
              p['name'] as String,
              keywordSets,
            );
          }

          if (p.containsKey('begin') && p.containsKey('beginCaptures')) {
            final beginRegex = p['begin'] as String;
            final captures = p['beginCaptures'] as Map<String, dynamic>;
            final groupContents = _extractCaptureGroups(beginRegex);
            captures.forEach((key, value) {
              if (value is Map<String, dynamic> && value.containsKey('name')) {
                final captureIndex = int.tryParse(key);

                if (captureIndex != null &&
                    captureIndex > 0 &&
                    captureIndex <= groupContents.length) {
                  final groupContent = groupContents[captureIndex - 1];
                  _tryExtractKeywords(
                    '\\b($groupContent)\\b',
                    value['name'] as String,
                    keywordSets,
                  );
                } else {
                  _tryExtractKeywords(
                    beginRegex,
                    value['name'] as String,
                    keywordSets,
                  );
                }
              }
            });
          }

          if (p.containsKey('begin') && p.containsKey('name')) {
            final beginRegex = p['begin'] as String;
            final groupContents = _extractCaptureGroups(beginRegex);
            for (final content in groupContents) {
              _tryExtractKeywords(
                '\\b($content)\\b',
                p['name'] as String,
                keywordSets,
              );
            }
          }
        }
      }

      if (entry.containsKey('match') && entry.containsKey('name')) {
        _tryExtractKeywords(
          entry['match'] as String,
          entry['name'] as String,
          keywordSets,
        );
      }
    }

    repository.forEach((key, value) {
      visitEntry(value, {key});
    });
  }

  static void _tryExtractKeywords(
    String regex,
    String scopeName,
    Map<String, Set<String>> keywordSets,
  ) {
    final className = _mapScopeToClassName(scopeName);
    if (className == null) return;

    const keywordCategories = {
      'keyword',
      'literal',
      'built_in',
      'type',
      'variable',
      'variable.language',
    };
    if (!keywordCategories.contains(className)) return;

    final words = _extractKeywordsFromRegex(regex);
    if (words != null && words.isNotEmpty) {
      keywordSets.putIfAbsent(className, () => <String>{});
      keywordSets[className]!.addAll(words);
    }
  }

  static List<String>? _extractKeywordsFromRegex(String regex) {
    final groupMatch = RegExp(
      r'(?:\\b)?\(?(?:\?[:<>=!][^)]*\))?(?:\\b)?\((?:\?:|\?<[!=][^)]*\))?\s*([^)]+)\)(?:\\b)?',
    ).firstMatch(regex);
    if (groupMatch != null) {
      final group = groupMatch.group(1)!;
      final parts = group.split('|');
      final words = <String>[];
      for (var part in parts) {
        part = part.trim();
        part = part.replaceAll(RegExp(r'\\s\+'), ' ');
        if (RegExp(
          r'^[a-zA-Z_][a-zA-Z0-9_]*(?:\s+[a-zA-Z_]+)*$',
        ).hasMatch(part)) {
          words.add(part);
        }
      }
      if (words.isNotEmpty) return words;
    }

    final singleMatch = RegExp(r'\\b([a-zA-Z_]\w*)\\b').firstMatch(regex);
    if (singleMatch != null) {
      return [singleMatch.group(1)!];
    }

    return null;
  }

  static List<String> _extractCaptureGroups(String regex) {
    final groups = <String>[];
    var depth = 0;
    var start = -1;
    var isNonCapturing = false;

    for (var i = 0; i < regex.length; i++) {
      if (regex[i] == '\\' && i + 1 < regex.length) {
        i++;
        continue;
      }

      if (regex[i] == '(') {
        if (depth == 0) {
          isNonCapturing = false;
          if (i + 1 < regex.length && regex[i + 1] == '?') {
            isNonCapturing = true;
          }
          start = i + 1;
        }
        depth++;
      } else if (regex[i] == ')') {
        depth--;
        if (depth == 0 && start >= 0 && !isNonCapturing) {
          var content = regex.substring(start, i);
          groups.add(content);
        }
      }
    }
    return groups;
  }

  static String _sanitizeRegex(String regex) {
    if (regex.isEmpty) return regex;
    var result = regex;
    result = result.replaceAllMapped(RegExp(r'([*+?])\+'), (m) => m.group(1)!);
    result = result.replaceAll('(?>', '(?:');
    result = result.replaceAllMapped(RegExp(r'\[\]'), (m) => '[\\]');
    result = result.replaceAll(r'\h', r'[0-9a-fA-F]');
    result = result.replaceAll(r'\H', r'[^0-9a-fA-F]');
    return result;
  }

  static bool _isValidRegex(String regex) {
    try {
      RegExp(regex);
      return true;
    } catch (_) {
      return false;
    }
  }
}
