part of 'view.dart';

extension _RendererCaret on _CodeFieldRenderer {
  void _publishCaretRect() {
    if (!vscrollController.hasClients || !hscrollController.hasClients) return;
    final caret = _getCaretInfo();
    final rect = Rect.fromLTWH(
      caret.offset.dx + _textLeft,
      caret.offset.dy + (innerPadding?.top ?? 0) - vscrollController.offset,
      0,
      caret.height,
    );
    final visible =
        rect.left >= _gutterWidth &&
        rect.left <= hscrollController.position.viewportDimension &&
        rect.top >= 0 &&
        rect.bottom <= vscrollController.position.viewportDimension;
    caretRectNotifier.value = visible ? rect : null;
  }

  void _ensureCaretVisible() {
    if (!vscrollController.hasClients || !hscrollController.hasClients) return;

    final caretInfo = _getCaretInfo();
    final caretX = caretInfo.offset.dx + _textLeft;
    final caretY = caretInfo.offset.dy + (innerPadding?.top ?? 0);
    final caretHeight = caretInfo.height;
    final vScrollOffset = vscrollController.offset;
    final hScrollOffset = hscrollController.offset;
    final viewportHeight =
        vscrollController.position.viewportDimension -
        (innerPadding?.bottom ?? 0);
    final viewportWidth =
        hscrollController.position.viewportDimension -
        (innerPadding?.right ?? 0);
    if (caretY >= 0 && caretY <= vScrollOffset + (innerPadding?.top ?? 0)) {
      final targetOffset = caretY - (innerPadding?.top ?? 0);
      vscrollController.jumpTo(
        targetOffset.clamp(0, vscrollController.position.maxScrollExtent),
      );
    } else if (caretY + caretHeight > vScrollOffset + viewportHeight) {
      final targetOffset = caretY + caretHeight - viewportHeight;
      vscrollController.jumpTo(
        targetOffset.clamp(0, vscrollController.position.maxScrollExtent),
      );
    }

    final textStart = _gutterWidth + (innerPadding?.left ?? 0);
    if (caretX < textStart) {
      final targetOffset = hScrollOffset + caretX - textStart;
      hscrollController.jumpTo(
        targetOffset.clamp(0, hscrollController.position.maxScrollExtent),
      );
    } else if (caretX + 1.5 > viewportWidth) {
      final targetOffset = hScrollOffset + caretX + 1.5 - viewportWidth;
      hscrollController.jumpTo(
        targetOffset.clamp(0, hscrollController.position.maxScrollExtent),
      );
    }
    _publishCaretRect();
  }

  void _scheduleCaretSyncAfterLayout() {
    if (_caretSyncAfterLayoutScheduled || _isFoldToggleInProgress) return;
    _caretSyncAfterLayoutScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _caretSyncAfterLayoutScheduled = false;
      if (!attached) return;
      if (!vscrollController.hasClients || !hscrollController.hasClients) {
        return;
      }
      _ensureCaretVisible();
    });
  }

  void _scrollToLine(int line) {
    if (line < 0 || line >= controller.lineCount) return;

    _unfoldAround(line);
    if (_foldLayoutPending) {
      // How far the view scrolls is only known once layout has the lines.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (attached) _scrollToLine(line);
      });
      return;
    }

    final targetY = _lineTop(line);
    final targetLineHeight = _lineExtent(line);
    final topPadding = innerPadding?.top ?? 0;
    final bottomPadding = innerPadding?.bottom ?? 0;
    final viewportHeight = vscrollController.position.viewportDimension;
    final visibleHeight = max(0.0, viewportHeight - topPadding - bottomPadding);
    final centerHeight = visibleHeight > 0 ? visibleHeight : viewportHeight;
    final maxScroll = vscrollController.position.maxScrollExtent;
    double scrollTarget = targetY + (targetLineHeight / 2) - (centerHeight / 2);

    scrollTarget = scrollTarget.clamp(0.0, maxScroll);

    vscrollController
        .animateTo(
          scrollTarget,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
        .then((_) {
          if (!attached) return;
          _highlightedLine = line;
          lineHighlightController.forward(from: 0.0);
        });
  }

  void _updateImeGeometry() {
    final conn = controller.connection;
    if (conn == null || !conn.attached) return;
    if (!vscrollController.hasClients || !hscrollController.hasClients) return;

    final caretInfo = _getCaretInfo();
    final vScroll = vscrollController.offset;
    final composing = controller.imeComposition != null;

    final caretY = caretInfo.offset.dy + (innerPadding?.top ?? 0);

    final caretInLine =
        caretInfo.offset.dx + (composing ? _imeComposingCaretDx : 0.0);
    final caretRect = Rect.fromLTWH(
      caretInLine + _textLeft,
      caretY - vScroll,
      2.0,
      caretInfo.height,
    );

    final composingRect = composing
        ? Rect.fromLTWH(
            caretInfo.offset.dx + _textLeft,
            caretY - vScroll,
            _imeComposingWidth > 0 ? _imeComposingWidth : 2.0,
            caretInfo.height,
          )
        : caretRect;

    final editableSize = size;

    if (caretRect == _lastImeCaretRect &&
        composingRect == _lastImeComposingRect &&
        editableSize == _lastImeEditableSize) {
      return;
    }
    _lastImeCaretRect = caretRect;
    _lastImeComposingRect = composingRect;
    _lastImeEditableSize = editableSize;

    conn.setEditableSizeAndTransform(editableSize, getTransformTo(null));
    conn.setCaretRect(caretRect);
    conn.setComposingRect(composingRect);
  }

  void _drawImeComposition(Canvas canvas, Offset offset, bool hasActiveFolds) {
    _imeComposingCaretDx = 0.0;
    _imeComposingWidth = 0.0;

    final comp = controller.imeComposition;
    if (comp == null || comp.displayText.isEmpty) return;

    final anchorLine = controller.getLineAtOffset(comp.anchor);
    if (hasActiveFolds && _isLineFolded(anchorLine)) return;

    final viewportHeight = vscrollController.position.viewportDimension;
    final viewportWidth = hscrollController.position.viewportDimension;
    final screenYBase = _screenY(offset, _lineTop(anchorLine));
    if (screenYBase + _lineHeight < offset.dy ||
        screenYBase > offset.dy + viewportHeight) {
      return;
    }

    final lineStartOffset = controller.getLineStartOffset(anchorLine);
    final lineText = _lineText(anchorLine);
    final anchorCol = lineText.toUtf16Offset(comp.anchor - lineStartOffset);
    final linePara = _paragraphFor(anchorLine);

    double anchorX = 0;
    double rowTop = 0;
    final anchorBox = _boxBefore(
      anchorLine,
      lineText,
      anchorCol,
      boxHeightStyle: ui.BoxHeightStyle.max,
    );
    if (anchorBox != null) {
      anchorX = anchorBox.right;
      rowTop = _rowTopForBox(anchorBox);
    }

    final screenX = _screenX(offset, anchorX);
    final screenY = screenYBase + rowTop;

    final baseColor =
        textStyle?.color ?? editorTheme['root']?.color ?? Colors.white;
    final bgColor = editorTheme['root']?.backgroundColor ?? Colors.black;
    final fontSize = textStyle?.fontSize ?? 14.0;
    final fontFamily = textStyle?.fontFamily;
    final overlayParagraphStyle = ui.ParagraphStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      height: textStyle?.height ?? 1.2,
      textDirection: TextDirection.ltr,
      textAlign: ui.TextAlign.start,
    );
    ui.Paragraph overlayParagraph(String text, ui.TextStyle style) {
      final builder = ui.ParagraphBuilder(overlayParagraphStyle)
        ..pushStyle(style)
        ..addText(text);
      return builder.build()
        ..layout(const ui.ParagraphConstraints(width: double.infinity));
    }

    final composingPara = overlayParagraph(
      comp.displayText,
      ui.TextStyle(
        color: baseColor,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontFamilyFallback: textStyle?.fontFamilyFallback,
        decoration: TextDecoration.underline,
        decorationColor: baseColor.withAlpha(150),
      ),
    );
    final composingWidth = composingPara.longestLine;

    final remainderWidth = (linePara.longestLine - anchorX).clamp(
      0.0,
      double.infinity,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        screenX,
        screenY,
        composingWidth + remainderWidth + 2,
        _lineHeight,
      ),
      Paint()..color = bgColor,
    );

    canvas.drawParagraph(composingPara, Offset(screenX, screenY));

    if (anchorCol < lineText.length) {
      final remainderEnd = SyntaxHighlighter.isPlain(lineText)
          ? linePara
                    .getClosestGlyphInfoForOffset(
                      Offset(anchorX + viewportWidth, _lineHeight / 2),
                    )
                    ?.graphemeClusterCodeUnitRange
                    .end ??
                lineText.length
          : lineText.length;
      final remainingPara = overlayParagraph(
        lineText.substring(anchorCol, max(anchorCol, remainderEnd)),
        ui.TextStyle(
          color: baseColor,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontFamilyFallback: textStyle?.fontFamilyFallback,
          fontWeight: textStyle?.fontWeight,
        ),
      );
      canvas.drawParagraph(
        remainingPara,
        Offset(screenX + composingWidth, screenY),
      );
    }

    double caretDx = 0;
    if (comp.displayCaret > 0) {
      final caretBoxes = composingPara.getBoxesForRange(
        0,
        comp.displayCaret.clamp(0, comp.displayText.length),
      );
      if (caretBoxes.isNotEmpty) caretDx = caretBoxes.last.right;
    }

    _imeComposingCaretDx = caretDx;
    _imeComposingWidth = composingWidth;

    if (focusNode.hasFocus && caretBlinkController.value > 0.5) {
      canvas.drawRect(
        Rect.fromLTWH(screenX + caretDx, screenY, 1.5, _lineHeight),
        _caretPainter,
      );
    }
  }

  void _selectWordAtOffset(int offset) {
    final line = controller.getLineAtOffset(offset);
    final lineStart = controller.getLineStartOffset(line);
    final text = _lineText(line);
    final column = text.toUtf16Offset(offset - lineStart);
    int start = column, end = column;

    while (start > 0 && isWordChar(text.codeUnitAt(start - 1))) {
      start--;
    }
    while (end < text.length && isWordChar(text.codeUnitAt(end))) {
      end++;
    }

    controller.selection = TextSelection(
      baseOffset: lineStart + text.toScalarOffset(start),
      extentOffset: lineStart + text.toScalarOffset(end),
    );
    markNeedsPaint();
  }

  void _paintMobileHandles(Canvas canvas, Offset offset) {
    final selection = controller.selection;
    final handleColor = selectionStyle.cursorBubbleColor;
    final handleRadius = _handleRadius;

    final handlePaint = Paint()
      ..color = handleColor
      ..style = PaintingStyle.fill;

    _normalHandle = null;
    if (selection.isCollapsed) {
      if (!_readOnly && (_showBubble || _selectionActive)) {
        final caretInfo = _getCaretInfo();
        final handleSize = caretInfo.height;

        final handleX = _screenX(offset, caretInfo.offset.dx);
        final handleY = _screenY(offset, caretInfo.offset.dy + _lineHeight);

        canvas.save();
        canvas.translate(handleX, handleY);
        canvas.rotate(pi / 4);
        _drawTeardrop(
          canvas,
          Rect.fromCenter(
            center: Offset((handleSize / 1.5), (handleSize / 1.5)),
            width: handleSize * 1.3,
            height: handleSize * 1.3,
          ),
          sharpCorner: _HandleCorner.topLeft,
          paint: handlePaint,
        );
        canvas.restore();

        _normalHandle = Rect.fromCenter(
          center: Offset(handleX, handleY + handleRadius),
          width: handleRadius * 2,
          height: handleRadius * 2,
        );
      }
    } else {
      if (_startHandleRect case final startRect?) {
        _drawTeardrop(
          canvas,
          startRect,
          sharpCorner: _HandleCorner.topRight,
          paint: handlePaint,
        );
      }

      if (_endHandleRect case final endRect?) {
        _drawTeardrop(
          canvas,
          endRect,
          sharpCorner: _HandleCorner.topLeft,
          paint: handlePaint,
        );
      }
    }
  }

  void _drawTeardrop(
    Canvas canvas,
    Rect rect, {
    required _HandleCorner sharpCorner,
    required Paint paint,
  }) {
    final round = Radius.circular(rect.shortestSide / 2);
    canvas.drawRSuperellipse(
      RSuperellipse.fromRectAndCorners(
        rect,
        topLeft: sharpCorner == _HandleCorner.topLeft ? Radius.zero : round,
        topRight: sharpCorner == _HandleCorner.topRight ? Radius.zero : round,
        bottomLeft: round,
        bottomRight: round,
      ),
      paint,
    );
  }

  int? get _magnifiedTextOffset {
    if (!isMobile) return null;
    final selection = controller.selection;
    if (selection.isCollapsed) {
      return _draggedHandle == _DraggedHandle.caret
          ? selection.baseOffset
          : null;
    }
    return switch (_draggedHandle) {
      _DraggedHandle.start => selection.start,
      _DraggedHandle.end => selection.end,
      _ => _selectionActive && _isDragging ? selection.extentOffset : null,
    };
  }

  // Paint runs after layout, so the caret geometry is final here, but the
  // overlay may only rebuild once the frame is done.
  void _publishMagnifier() {
    final textOffset = _magnifiedTextOffset;
    MagnifierInfo? info;
    if (textOffset != null) {
      final line = controller.getLineAtOffset(textOffset);
      final anchor = _selectionHandleAnchor(
        Offset.zero,
        line,
        textOffset - controller.getLineStartOffset(line),
      );
      final origin = localToGlobal(Offset.zero);
      info = MagnifierInfo(
        globalGesturePosition: localToGlobal(_currentPosition),
        caretRect: Rect.fromLTWH(
          anchor.dx,
          anchor.dy,
          0,
          _lineHeight,
        ).shift(origin),
        fieldBounds: origin & size,
        currentLineBoundaries: Rect.fromLTWH(
          0,
          anchor.dy,
          size.width,
          _lineHeight,
        ).shift(origin),
      );
    }
    if (magnifierNotifier.value == info) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) magnifierNotifier.value = info;
    });
  }
}

enum _HandleCorner { topLeft, topRight }

extension _RendererGutter on _CodeFieldRenderer {
  bool _shouldShortenGuideToPreviousLine(String lineText) {
    final trimmed = lineText.trimRight();
    return trimmed.endsWith('{') ||
        trimmed.endsWith('(') ||
        trimmed.endsWith('[');
  }

  void _drawGutter(
    Canvas canvas,
    Offset offset,
    Color bgColor,
    TextStyle? gutterTextStyle,
  ) {
    final viewportHeight = vscrollController.position.viewportDimension;

    final gutterBgColor = gutterStyle.backgroundColor ?? bgColor;
    final gutterX = offset.dx;
    canvas.drawRect(
      Rect.fromLTWH(gutterX, offset.dy, _gutterWidth, viewportHeight),
      Paint()..color = gutterBgColor,
    );
    if (gutterStyle.dividerColor case final dividerColor?) {
      final dividerX = gutterX + _gutterWidth - 0.5;
      canvas.drawLine(
        Offset(dividerX, offset.dy),
        Offset(dividerX, offset.dy + viewportHeight),
        Paint()
          ..color = dividerColor
          ..strokeWidth = 1,
      );
    }

    final baseLineNumberStyle = (() {
      if (gutterTextStyle == null) {
        return editorTheme['root'];
      } else if (gutterTextStyle.color == null) {
        return gutterTextStyle.copyWith(color: editorTheme['root']?.color);
      } else {
        return gutterTextStyle;
      }
    })();

    final selection = controller.selection;
    final activeFirstLine = controller.getLineAtOffset(selection.start);
    var activeLastLine = controller.getLineAtOffset(selection.end);
    if (activeLastLine > activeFirstLine &&
        controller.getLineStartOffset(activeLastLine) == selection.end) {
      activeLastLine--;
    }

    final activeLineColor = baseLineNumberStyle?.color ?? Colors.white;
    final inactiveLineColor =
        baseLineNumberStyle?.color?.withAlpha(120) ?? Colors.grey;

    for (final i in _paintLines) {
      final contentTop = _lineTop(i);

      final lineNumberStyle = baseLineNumberStyle!.copyWith(
        fontSize: _lineNumberFontSize,
        color: i >= activeFirstLine && i <= activeLastLine
            ? activeLineColor
            : inactiveLineColor,
      );

      final lineNumPara = _buildLineNumberParagraph(
        '${i + 1}',
        lineNumberStyle,
      );
      final numWidth = lineNumPara.longestLine;

      canvas.drawParagraph(
        lineNumPara,
        Offset(
          offset.dx +
              (_CodeFieldRenderer._gutterInset +
                      _gutterWidth -
                      _foldIconStripWidth -
                      numWidth) /
                  2,
          _screenY(offset, contentTop) + (_lineHeight - lineNumPara.height) / 2,
        ),
      );

      final foldRange = _getFoldRangeAtLine(i);
      if (foldRange != null && foldRange.endIndex > foldRange.startIndex) {
        final isInsideFoldedParent = _isLineFolded(i);

        if (!isInsideFoldedParent) {
          final icon = foldRange.isFolded
              ? Icons.chevron_right_outlined
              : Icons.keyboard_arrow_down_outlined;
          final iconColor = gutterStyle.foldIconColor ?? lineNumberStyle.color;

          _drawFoldIcon(
            canvas,
            offset,
            icon,
            iconColor!,
            _foldIconSize,
            contentTop,
          );
        }
      }
    }
  }

  ui.Paragraph _buildLineNumberParagraph(String text, TextStyle style) {
    final builder = ui.ParagraphBuilder(style.getParagraphStyle())
      ..pushStyle(style.getTextStyle())
      ..addText(text);
    final p = builder.build();
    p.layout(const ui.ParagraphConstraints(width: double.infinity));
    return p;
  }

  void _drawFoldIcon(
    Canvas canvas,
    Offset offset,
    IconData icon,
    Color color,
    double fontSize,
    double contentTop,
  ) {
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    final iconX =
        offset.dx +
        _gutterWidth -
        (_foldIconStripWidth + iconPainter.width) / 2;
    iconPainter.paint(
      canvas,
      Offset(
        iconX,
        _screenY(offset, contentTop) + (_lineHeight - iconPainter.height) / 2,
      ),
    );
    iconPainter.dispose();
  }

  void _drawIndentGuides(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    Color textColor,
  ) {
    final viewTop = _paintViewTop;
    final viewBottom = viewTop + vscrollController.position.viewportDimension;
    final tabSize = controller.tabSize;
    final cursorOffset = controller.selection.extentOffset;
    final currentLine = controller.getLineAtOffset(cursorOffset);
    final List<({int startLine, int endLine, int indentLevel, double guideX})>
    blocks = [];

    final scanStart = (firstVisibleLine - 500).clamp(0, firstVisibleLine);

    double measureLeadingIndentWidth(String lineText, int leadingColumns) {
      if (leadingColumns <= 0 || lineText.isEmpty) return 0;

      int consumedColumns = 0;
      int endIndex = 0;

      while (endIndex < lineText.length && consumedColumns < leadingColumns) {
        final ch = lineText[endIndex];
        if (ch == ' ') {
          consumedColumns += 1;
        } else if (ch == '\t') {
          consumedColumns = tabSize <= 0
              ? consumedColumns + 1
              : consumedColumns + (tabSize - (consumedColumns % tabSize));
        } else {
          break;
        }
        endIndex++;
      }

      if (endIndex == 0) return 0;

      final indentString = lineText.substring(0, endIndex);
      final builder = ui.ParagraphBuilder(_paragraphStyle)
        ..pushStyle(_uiTextStyle)
        ..addText(indentString);
      final spacePara = builder.build();
      spacePara.layout(const ui.ParagraphConstraints(width: double.infinity));
      return spacePara.maxIntrinsicWidth;
    }

    void addBlock({
      required int startLine,
      required int endLine,
      required int leadingColumns,
      required int indentLevel,
      required String lineText,
    }) {
      if (endLine <= startLine) return;

      final renderEndLine = max(
        _shouldShortenGuideToPreviousLine(lineText)
            ? (endLine - 1).clamp(startLine + 1, endLine)
            : endLine,
        startLine + 2,
      );

      // Only the guide's x is reused: its end depends on the viewport, since
      // guidesComputeViewport stops scanning just below it.
      final cachedBlocks = _indentGuideCache[startLine];
      final guideX = cachedBlocks != null && cachedBlocks.isNotEmpty
          ? cachedBlocks.first.guideX
          : leadingColumns > 0
          ? measureLeadingIndentWidth(lineText, leadingColumns)
          : 0.0;

      final block = (
        startLine: startLine,
        endLine: renderEndLine,
        indentLevel: indentLevel,
        guideX: guideX,
      );

      _indentGuideCache[startLine] = [block];
      if (renderEndLine >= firstVisibleLine) {
        blocks.add(block);
      }
    }

    final foldedGuideCandidates = <int, FoldRange>{};
    for (
      int i = scanStart;
      i <= lastVisibleLine && i < controller.lineCount;
      i++
    ) {
      final fold = _foldRanges[i];
      if (fold != null) {
        foldedGuideCandidates[i] = fold;
      }
    }

    final rustBlocks = guidesComputeViewport(
      rope: controller.rope.core,
      firstVisible: BigInt.from(firstVisibleLine),
      lastVisible: BigInt.from(lastVisibleLine),
      tabSize: BigInt.from(tabSize),
    );

    for (final b in rustBlocks) {
      final lineText = _lineText(b.startLine);

      addBlock(
        startLine: b.startLine,
        endLine: b.endLine,
        leadingColumns: b.leadingSpaces,
        indentLevel: b.indentLevel,
        lineText: lineText,
      );
    }

    if (foldedGuideCandidates.isNotEmpty) {
      for (final entry in foldedGuideCandidates.entries) {
        final lineIndex = entry.key;
        final fold = entry.value;

        final lineText = _lineText(lineIndex);

        final alreadyAdded = blocks.any(
          (block) => block.startLine == lineIndex,
        );
        if (alreadyAdded) {
          continue;
        }

        final leadingColumns = _measureLeadingIndentColumns(lineText);
        final indentLevel = _lineIndentCache.containsKey(lineIndex)
            ? _lineIndentCache[lineIndex]!
            : (tabSize > 0 ? leadingColumns ~/ tabSize : leadingColumns);
        if (!_lineIndentCache.containsKey(lineIndex)) {
          _lineIndentCache[lineIndex] = indentLevel;
        }

        addBlock(
          startLine: lineIndex,
          endLine: fold.endIndex + 1,
          leadingColumns: leadingColumns,
          indentLevel: indentLevel,
          lineText: lineText,
        );
      }
    }

    int? selectedBlockIndex;
    int minBlockSize = 999999;

    for (int idx = 0; idx < blocks.length; idx++) {
      final block = blocks[idx];
      if (currentLine >= block.startLine && currentLine < block.endLine) {
        final blockSize = block.endLine - block.startLine;
        if (blockSize < minBlockSize) {
          minBlockSize = blockSize;
          selectedBlockIndex = idx;
        }
      }
    }

    for (int idx = 0; idx < blocks.length; idx++) {
      final block = blocks[idx];
      final isSelected = selectedBlockIndex == idx;

      final guidePaint = Paint()
        ..color = isSelected ? textColor : textColor.withAlpha(100)
        ..strokeWidth = isSelected ? 1.0 : 0.5
        ..style = PaintingStyle.stroke;

      final screenYTop = _screenY(offset, _lineTop(block.startLine + 1));
      final screenYBottom = _screenY(offset, _lineTop(block.endLine));

      if (screenYBottom < 0 || screenYTop > viewBottom - viewTop) continue;

      final screenGuideX = _screenX(offset, block.guideX);

      if (screenGuideX < offset.dx + _gutterWidth ||
          screenGuideX > offset.dx + size.width) {
        continue;
      }

      final clampedYTop = screenYTop.clamp(0.0, viewBottom - viewTop);
      final clampedYBottom = screenYBottom.clamp(0.0, viewBottom - viewTop);

      canvas.drawLine(
        Offset(screenGuideX, clampedYTop),
        Offset(screenGuideX, clampedYBottom),
        guidePaint,
      );
    }
  }
}

extension _RendererCoordinates on _CodeFieldRenderer {
  double get _textLeft =>
      _gutterWidth +
      (innerPadding?.left ?? 0) -
      (lineWrap ? 0 : hscrollController.offset);

  double _screenX(Offset offset, double contentX) =>
      offset.dx + _textLeft + contentX;

  double _screenY(Offset offset, double contentY) =>
      offset.dy +
      (innerPadding?.top ?? 0) +
      contentY -
      vscrollController.offset;
}

extension _RendererHighlights on _CodeFieldRenderer {
  void _pauseBracketHighlightDuringTyping() {
    _suspendBracketHighlight = true;
    _bracketHighlightResumeTimer?.cancel();
    _bracketHighlightResumeTimer = Timer(const Duration(milliseconds: 500), () {
      _suspendBracketHighlight = false;
      markNeedsPaint();
    });
  }

  (int?, int?) _getBracketPairAtCursor() {
    if (_suspendBracketHighlight) return (null, null);

    final cursorOffset = controller.selection.extentOffset;
    final textLength = controller.length;
    const bracketChars = '{}[]()';
    const openingBracketChars = '{[(';

    if (cursorOffset < 0 || textLength == 0) return (null, null);

    if (cursorOffset > 0 && cursorOffset <= textLength) {
      final before = controller.rope.substring(cursorOffset - 1, cursorOffset);
      if (bracketChars.contains(before)) {
        final match = _findMatchingBracket(cursorOffset - 1);
        if (match != null) {
          return (cursorOffset - 1, match);
        }
      }
    }

    if (cursorOffset >= 0 && cursorOffset < textLength) {
      final after = controller.rope.substring(cursorOffset, cursorOffset + 1);
      if (openingBracketChars.contains(after)) {
        final match = _findMatchingBracket(cursorOffset);
        if (match != null) {
          return (cursorOffset, match);
        }
      }
    }

    return (null, null);
  }

  void _drawBracketHighlight(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    bool hasActiveFolds,
    Color textColor,
  ) {
    if (!controller.selection.isValid || !controller.selection.isCollapsed) {
      return;
    }

    if (_suspendBracketHighlight) {
      return;
    }

    final (bracket1, bracket2) = _getBracketPairAtCursor();
    if (bracket1 == null || bracket2 == null) return;

    for (final bracket in [bracket1, bracket2]) {
      final line = controller.getLineAtOffset(bracket);
      if (line >= firstVisibleLine &&
          line <= lastVisibleLine &&
          (!hasActiveFolds || !_isLineFolded(line))) {
        _drawBracketBox(canvas, offset, bracket, line, textColor);
      }
    }
  }

  void _drawBracketBox(
    Canvas canvas,
    Offset offset,
    int bracketOffset,
    int lineIndex,
    Color textColor,
  ) {
    final lineStartOffset = controller.getLineStartOffset(lineIndex);
    final columnIndex = bracketOffset - lineStartOffset;

    final lineText = _lineText(lineIndex);

    if (columnIndex < 0 || columnIndex >= lineText.length) return;

    final para = _paragraphFor(lineIndex);

    final utf16Col = lineText.toUtf16Offset(columnIndex);
    final boxes = para.getBoxesForRange(utf16Col, utf16Col + 1);
    if (boxes.isEmpty) return;

    final box = boxes.first;

    final screenX = _screenX(offset, box.left);
    final screenY = _screenY(offset, _lineTop(lineIndex) + box.top);

    final bracketRect = RSuperellipse.fromRectAndRadius(
      Rect.fromLTWH(
        screenX - 1.5,
        screenY - 1,
        box.right - box.left + 3,
        _lineHeight + 2.5,
      ),
      const Radius.circular(2),
    );

    _bracketHighlightPainter.color = textColor;
    canvas.drawRSuperellipse(bracketRect, _bracketHighlightPainter);
  }

  // Each visible line walks its shown text once for the matches in it,
  // however many a long line holds.
  void _drawSearchHighlights(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
  ) {
    final highlights = controller.searchHighlights;
    if (highlights.isEmpty) return;
    final current = Paint()..color = const Color(0xFF01A2FF);
    final other = Paint()..color = const Color.fromARGB(163, 72, 215, 255);
    for (final line in _paintLines) {
      if (line < firstVisibleLine || line > lastVisibleLine) continue;
      final text = _lineText(line);
      final paragraph = _paragraphFor(line);
      final slice = _sliceInView(line, text, paragraph);
      final lineStart = controller.getLineStartOffset(line);
      final shownStart = lineStart + (slice?.scalarStart ?? 0);
      final shownEnd = lineStart + (slice?.scalarEnd ?? text.runes.length);
      final origin = _lineOrigin(offset, line);
      var scalar = shownStart;
      var utf16 = slice?.start ?? 0;
      int column(int offset) {
        utf16 = text.utf16After(utf16, offset - scalar);
        scalar = offset;
        return utf16;
      }

      var low = 0, high = highlights.length;
      while (low < high) {
        final mid = (low + high) >> 1;
        if (highlights[mid].end <= shownStart) {
          low = mid + 1;
        } else {
          high = mid;
        }
      }
      for (var i = low; i < highlights.length; i++) {
        final highlight = highlights[i];
        if (highlight.start >= shownEnd) break;
        _fillRange(
          canvas,
          origin,
          slice,
          paragraph,
          column(max(highlight.start, shownStart)),
          column(min(highlight.end, shownEnd)),
          highlight.isCurrentMatch ? current : other,
        );
      }
    }
  }

  void _drawFoldedLineHighlights(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    bool hasActiveFolds,
  ) {
    if (!hasActiveFolds) return;

    final highlightColor = selectionStyle.selectionColor.withAlpha(60);

    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    for (final foldRange in controller.foldings.values.where(
      (f) => f != null,
    )) {
      if (!foldRange!.isFolded) continue;

      final foldStartLine = foldRange.startIndex;

      if (foldStartLine < firstVisibleLine || foldStartLine > lastVisibleLine) {
        continue;
      }

      final lineHeight = _lineExtent(foldStartLine);
      final screenY = _screenY(offset, _lineTop(foldStartLine));

      final highlightX = offset.dx + _gutterWidth;
      final highlightWidth = size.width - _gutterWidth;

      canvas.drawRect(
        Rect.fromLTWH(highlightX, screenY, highlightWidth, lineHeight),
        highlightPaint,
      );
    }
  }

  void _drawSelection(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
  ) {
    _startHandleRect = _endHandleRect = null;
    final selection = controller.selection;
    if (selection.isCollapsed) return;

    final start = selection.start;
    final end = selection.end;
    final startLine = controller.getLineAtOffset(start);
    final endLine = controller.getLineAtOffset(end);
    if (endLine < firstVisibleLine || startLine > lastVisibleLine) return;

    final selectionPaint = Paint()
      ..color = selectionStyle.selectionColor
      ..style = PaintingStyle.fill;
    _drawRangeRows(
      canvas,
      offset,
      start,
      end,
      startLine,
      endLine,
      selectionPaint,
      markEmptyLines: true,
    );

    _updateSelectionHandleRects(offset, start, end, startLine, endLine);
  }

  // [markEmptyLines] gives a line the range crosses without covering any of
  // its text a short block at its end, so the line break reads as selected.
  void _drawRangeRows(
    Canvas canvas,
    Offset offset,
    int start,
    int end,
    int startLine,
    int endLine,
    Paint paint, {
    bool markEmptyLines = false,
  }) {
    for (final line in _paintLines) {
      if (line < startLine || line > endLine) continue;

      final lineStart = controller.getLineStartOffset(line);
      final lineText = _lineText(line);
      final utf16Start = lineText.toUtf16Offset(start - lineStart);
      final utf16End = lineText.toUtf16Offset(end - lineStart);

      if (utf16Start < utf16End) {
        final para = _paragraphFor(line);
        _fillRange(
          canvas,
          _lineOrigin(offset, line),
          _sliceInView(line, lineText, para),
          para,
          utf16Start,
          utf16End,
          paint,
        );
      } else if (markEmptyLines && line < endLine) {
        final lineEnd = _selectionHandleAnchor(offset, line, start - lineStart);
        canvas.drawRect(lineEnd & Size(8, _lineHeight), paint);
      }
    }
  }

  Offset _lineOrigin(Offset offset, int line) =>
      Offset(_screenX(offset, 0), _screenY(offset, _lineTop(line)));

  void _fillRange(
    Canvas canvas,
    Offset origin,
    _LineSlice? slice,
    ui.Paragraph paragraph,
    int from,
    int to,
    Paint paint,
  ) {
    final start = max(from, slice?.start ?? 0);
    final end = min(to, slice?.end ?? to);
    if (start >= end) return;
    final shown = slice?.paragraph ?? paragraph;
    final shift = slice?.start ?? 0;
    final at = origin + (slice?.origin ?? Offset.zero);
    final boxes = shown.getBoxesForRange(start - shift, end - shift);
    for (final row in _selectionRows(shown, boxes)) {
      canvas.drawRect(row.shift(at), paint);
    }
  }

  // One rect per visual row, spanning the row's full height: a style run or
  // fallback glyph gets its own box with its own font's extent, and stacked
  // translucent boxes would darken where they overlap.
  List<Rect> _selectionRows(ui.Paragraph para, List<ui.TextBox> boxes) {
    if (boxes.isEmpty) return const [];
    final rows = lineWrap
        ? [
            for (final metrics in para.computeLineMetrics())
              (
                top: metrics.baseline - metrics.ascent,
                bottom: metrics.baseline + metrics.descent,
              ),
          ]
        : [(top: 0.0, bottom: _lineHeight)];
    final spans = <int, Rect>{};
    for (final box in boxes) {
      final center = (box.top + box.bottom) / 2;
      var row = rows.indexWhere((row) => center < row.bottom);
      if (row < 0) row = rows.length - 1;
      final rect = Rect.fromLTRB(
        box.left,
        rows[row].top,
        box.right,
        rows[row].bottom,
      );
      spans.update(row, rect.expandToInclude, ifAbsent: () => rect);
    }
    return spans.values.toList();
  }

  void _updateSelectionHandleRects(
    Offset offset,
    int start,
    int end,
    int startLine,
    int endLine,
  ) {
    final handleRadius = _handleRadius;
    final handleSize = _handleSize;

    Rect handleBelow(int line, int offsetInDocument, double dx) {
      final anchor = _selectionHandleAnchor(
        offset,
        line,
        offsetInDocument - controller.getLineStartOffset(line),
      );
      return Rect.fromCenter(
        center: anchor.translate(dx, _lineHeight + handleRadius),
        width: handleSize,
        height: handleSize,
      );
    }

    if (_paintLines.contains(startLine)) {
      _startHandleRect = handleBelow(startLine, start, -_handleOverhang);
    }
    if (_paintLines.contains(endLine)) {
      _endHandleRect = handleBelow(endLine, end, _handleOverhang);
    }
  }

  Rect? getVisibleSelectionRect() {
    final selection = controller.selection;
    if (selection.isCollapsed) return null;
    double rowTop(int offset) {
      final line = controller.getLineAtOffset(offset);
      final text = _lineText(line);
      final box = _boxBefore(
        line,
        text,
        text.toUtf16Offset(offset - controller.getLineStartOffset(line)),
      );
      final top = box == null ? 0.0 : _rowTopForBox(box);
      return _screenY(Offset.zero, _lineTop(line) + top);
    }

    final rows = Rect.fromLTRB(
      _gutterWidth,
      rowTop(selection.start),
      size.width,
      rowTop(selection.end - 1) + _lineHeight + (isMobile ? _handleSize : 0),
    ).intersect(Offset.zero & size);
    return rows.isEmpty
        ? null
        : Rect.fromPoints(
            localToGlobal(rows.topLeft),
            localToGlobal(rows.bottomRight),
          );
  }

  Offset _selectionHandleAnchor(Offset offset, int line, int column) {
    final lineText = _lineText(line);
    final box = _boxBefore(line, lineText, lineText.toUtf16Offset(column));
    return Offset(
      _screenX(offset, box?.right ?? 0),
      _screenY(offset, _lineTop(line) + (box?.top ?? 0)),
    );
  }

  void _drawLineHighlight(
    Canvas canvas,
    Offset offset,
    int firstVisibleLine,
    int lastVisibleLine,
    bool hasActiveFolds,
  ) {
    if (_highlightedLine == null) return;

    final highlightLine = _highlightedLine!;

    if (highlightLine < firstVisibleLine || highlightLine > lastVisibleLine) {
      return;
    }

    if (hasActiveFolds && _isLineFolded(highlightLine)) return;

    final opacity = _lineHighlightAnimation.value;
    if (opacity <= 0.0) {
      _highlightedLine = null;
      return;
    }

    final lineHeight = _lineExtent(highlightLine);
    final screenY = _screenY(offset, _lineTop(highlightLine));
    final screenX = _screenX(offset, 0);

    final highlightColor =
        (textStyle?.color ?? editorTheme['root']?.color ?? Colors.yellow)
            .withValues(alpha: opacity);

    final paint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.fill;

    final width = size.width - _gutterWidth - (innerPadding?.horizontal ?? 0);
    canvas.drawRect(Rect.fromLTWH(screenX, screenY, width, lineHeight), paint);
  }
}

// Up to this many lines, a line's fold is found as it is painted; a longer
// document is folded in one pass off the UI isolate.
const _perLineFoldLimit = 10000;

extension _RendererFolding on _CodeFieldRenderer {
  bool get _foldsInBackground => controller.lineCount > _perLineFoldLimit;

  void _adoptControllerFolds() {
    _foldRanges.addAll({
      for (final fold in controller.foldings.values.nonNulls)
        if (fold.isFolded &&
            fold.endIndex < controller.lineCount &&
            _stillFolds(fold))
          fold.startIndex: fold,
    });
    controller.foldings = Map.of(_foldRanges);
  }

  void _invalidateFoldRanges() {
    _foldRanges.clear();
    _foldedLineCacheDirty = true;
    if (_foldsInBackground) _scheduleAsyncFoldComputation();
  }

  // A folded range, or one it remembers, is kept only while the text still
  // gives it: a stale one would hide lines that no longer belong to it.
  void _applyLineEditToFolds(({int line, int removed, int inserted}) edit) {
    final withinLine = edit.removed == 0 && edit.inserted == 0;
    if (withinLine && _foldsInBackground) {
      if (_foldRanges[edit.line]?.isFolded == false) {
        _foldRanges.remove(edit.line);
      }
      _foldedLineCacheDirty = true;
      if (!_asyncFoldComputationPending) _scheduleAsyncFoldComputation();
      return;
    }
    final last = edit.line + edit.removed;
    final delta = edit.inserted - edit.removed;
    final remembered = _rememberedFolds();
    final folds = Set<FoldRange>.identity()
      ..addAll(_foldRanges.values.nonNulls)
      ..addAll(remembered);
    final kept = Map<FoldRange, FoldRange>.identity();
    for (final fold in folds) {
      final start = fold.startIndex, end = fold.endIndex;
      final FoldRange? after;
      if (end < edit.line) {
        after = _lengthenedBy(fold, edit.line) ? null : fold;
      } else if (start > last) {
        after = fold._moved(start + delta, end + delta);
      } else if (fold.isFolded || remembered.contains(fold)) {
        after = _touchedFoldAfter(fold, edit);
      } else {
        after = _touchedCachedFoldAfter(fold, edit);
      }
      if (after != null) kept[fold] = after;
    }
    final unfolds = folds.any(
      (fold) => fold.isFolded && !kept.containsKey(fold),
    );
    if (!withinLine) {
      _foldRanges
        ..clear()
        ..addAll({for (final fold in kept.values) fold.startIndex: fold});
    } else {
      _foldRanges.removeWhere(
        (line, fold) =>
            fold == null ? line <= edit.line : !kept.containsKey(fold),
      );
    }
    _passOnRememberedFolds(folds, (fold) => kept[fold]);
    if (!withinLine || unfolds) {
      _commitFoldChange();
    } else {
      _foldedLineCacheDirty = true;
    }
    if (_foldsInBackground && !_asyncFoldComputationPending) {
      _scheduleAsyncFoldComputation();
    }
  }

  Set<FoldRange> _rememberedFolds() {
    final remembered = Set<FoldRange>.identity();
    void collect(FoldRange fold) {
      for (final child in fold.originallyFoldedChildren) {
        if (remembered.add(child)) collect(child);
      }
    }

    _foldRanges.values.nonNulls.forEach(collect);
    return remembered;
  }

  /// Hands what [folds] remember on to what [after] makes of them, and folds
  /// what a folded one that went had remembered.
  void _passOnRememberedFolds(
    Iterable<FoldRange> folds,
    FoldRange? Function(FoldRange fold) after,
  ) {
    Iterable<FoldRange> survivors(FoldRange fold) sync* {
      for (final child in fold.originallyFoldedChildren) {
        final kept = after(child);
        if (kept != null) {
          yield kept;
        } else {
          yield* survivors(child);
        }
      }
    }

    final remembered = [
      for (final fold in folds) (fold, survivors(fold).toList()),
    ];
    for (final (fold, children) in remembered) {
      final kept = after(fold);
      if (kept != null) {
        kept.originallyFoldedChildren = children;
      } else if (fold.isFolded) {
        for (final child in children.where(_stillFolds)) {
          _foldRanges[child.startIndex] = child..isFolded = true;
        }
      }
    }
  }

  bool _lengthenedBy(FoldRange fold, int editedLine) {
    if (!fold.isFolded || _foldsInBackground) return false;
    for (var line = fold.endIndex + 1; line < editedLine; line++) {
      if (controller.getLineText(line).trim().isNotEmpty) return false;
    }
    return !_stillFolds(fold);
  }

  FoldRange? _touchedCachedFoldAfter(
    FoldRange fold,
    ({int line, int removed, int inserted}) edit,
  ) {
    final start = fold.startIndex, end = fold.endIndex;
    final withinLine = edit.removed == 0 && edit.inserted == 0;
    final holdsEdit = withinLine || end > edit.line + edit.removed;
    if (start >= edit.line || !holdsEdit) return null;
    if (!_foldsInBackground) _scheduleFoldCacheRecheck();
    return fold._moved(start, end + edit.inserted - edit.removed);
  }

  void _scheduleFoldCacheRecheck() {
    _foldCacheRecheckTimer?.cancel();
    _foldCacheRecheckTimer = Timer(const Duration(milliseconds: 300), () {
      _foldRanges.removeWhere((_, fold) => fold != null && !fold.isFolded);
      markNeedsPaint();
    });
  }

  FoldRange? _touchedFoldAfter(
    FoldRange fold,
    ({int line, int removed, int inserted}) edit,
  ) {
    final start = fold.startIndex, end = fold.endIndex;
    final delta = edit.inserted - edit.removed;
    final withinLine = delta == 0 && edit.removed == 0;
    if (start < edit.line || withinLine) {
      final grown = fold._moved(start, end + delta);
      if (_foldsInBackground) {
        return withinLine || end > edit.line + edit.removed ? grown : null;
      }
      return _foldsAt(grown) ? grown : null;
    }
    // The edit names the lines that changed, not where in them: only a fold
    // heading the first or the last has a place the text can confirm.
    final places = [
      if (delta == 0 || start == edit.line) fold,
      if (delta != 0 && start == edit.line + edit.removed)
        fold._moved(start + delta, end + delta),
    ].where(_foldsAt).toList();
    return places.length == 1 ? places.single : null;
  }

  bool _foldsAt(FoldRange range) =>
      range.endIndex > range.startIndex &&
      range.startIndex < controller.lineCount &&
      _computeFoldRangeForLine(range.startIndex) == range;

  // Past the per-line limit, the whole-document pass decides once it lands.
  bool _stillFolds(FoldRange fold) => _foldsInBackground || _foldsAt(fold);

  void _rebuildFoldedLineCache() {
    if (_layout.lineCount != controller.lineCount) {
      final edit = controller.pendingLineEdit;
      if (edit == null || !_spliceLayout(edit)) {
        _layout.reset(controller.lineCount);
        _wrappedRowEstimateStale = true;
      }
    }
    final hidden = <({int start, int end})>[];
    for (final fold in _foldRanges.values) {
      if (fold != null && fold.isFolded) {
        hidden.add((start: fold.startIndex + 1, end: fold.endIndex + 1));
      }
    }
    _hasActiveFoldsCache = hidden.isNotEmpty;
    _layout.setHiddenRanges(hidden);
    _caretInfoCache.clear();
    _foldedLineCacheDirty = false;
  }

  void _ensureFoldedLineCacheValid() {
    if (_foldedLineCacheDirty || _layout.lineCount != controller.lineCount) {
      _rebuildFoldedLineCache();
    }
  }

  bool get _hasActiveFolds {
    _ensureFoldedLineCacheValid();
    return _hasActiveFoldsCache;
  }

  void _scheduleAsyncFoldComputation() {
    _foldComputeTimer?.cancel();
    _foldComputeTimer = Timer(const Duration(milliseconds: 300), () {
      _runAsyncFoldComputation();
    });
  }

  Future<void> _runAsyncFoldComputation() async {
    // Buffered typing is in the version before it is in the rope read here.
    if (controller.isBufferActive) {
      _scheduleAsyncFoldComputation();
      return;
    }
    _asyncFoldComputationPending = true;
    final version = controller.contentVersion;

    try {
      final computed = await foldsComputeAll(
        rope: controller.rope.core,
        tabSize: BigInt.from(controller.tabSize),
      );
      if (!attached) {
        _asyncFoldComputationPending = false;
        return;
      }
      if (controller.contentVersion != version) {
        _asyncFoldComputationPending = false;
        _scheduleAsyncFoldComputation();
        return;
      }

      final folds = {
        for (final fold in computed)
          fold.startLine: FoldRange(fold.startLine, fold.endLine),
      };
      final before = Set<FoldRange>.identity()
        ..addAll(_foldRanges.values.nonNulls)
        ..addAll(_rememberedFolds());
      for (final fold in before) {
        if (folds[fold.startIndex] == fold) folds[fold.startIndex] = fold;
      }
      bool survives(FoldRange fold) => identical(folds[fold.startIndex], fold);
      final unfolds = before.any((fold) => fold.isFolded && !survives(fold));
      _foldRanges
        ..clear()
        ..addAll(folds);
      _passOnRememberedFolds(before, (fold) => survives(fold) ? fold : null);
      _asyncFoldComputationPending = false;
      _asyncFoldsVersion = version;
      if (unfolds) {
        _commitFoldChange();
      } else {
        markNeedsPaint();
      }
    } catch (e) {
      _asyncFoldComputationPending = false;
      debugPrint('Error computing folds in isolate: $e');
    }
  }

  // Kept in step with `compute_all` in rust_api's editor/folds.rs.
  FoldRange? _computeFoldRangeForLine(int lineIndex) {
    final line = controller.getLineText(lineIndex);
    final bracketEnd = _bracketFoldEnd(lineIndex);
    final indentEnd = line.trimRight().endsWith(':')
        ? _indentFoldEnd(lineIndex, line)
        : null;
    final end = bracketEnd == null || indentEnd == null
        ? bracketEnd ?? indentEnd
        : min(bracketEnd, indentEnd);
    return end == null ? null : FoldRange(lineIndex, end);
  }

  int? _bracketFoldEnd(int lineIndex) {
    final own = [0, 0, 0], nested = [0, 0, 0];
    for (var i = lineIndex; i < controller.lineCount; i++) {
      for (final unit in controller.getLineText(i).codeUnits) {
        final kind = switch (unit) {
          0x7B || 0x7D => 0,
          0x5B || 0x5D => 1,
          0x28 || 0x29 => 2,
          _ => null,
        };
        if (kind == null) continue;
        if (unit == 0x7B || unit == 0x5B || unit == 0x28) {
          (i == lineIndex ? own : nested)[kind]++;
        } else if (nested[kind] > 0) {
          nested[kind]--;
        } else if (own[kind] > 0) {
          if (i > lineIndex) return i;
          own[kind]--;
        }
      }
      if (own.every((count) => count == 0)) return null;
    }
    return null;
  }

  int _measureLeadingIndentColumns(String lineText) {
    final tabSize = controller.tabSize;
    int columns = 0;

    for (int i = 0; i < lineText.length; i++) {
      final ch = lineText[i];
      if (ch == ' ') {
        columns += 1;
      } else if (ch == '\t') {
        final nextStop = tabSize <= 0
            ? columns + 1
            : columns + (tabSize - (columns % tabSize));
        columns = nextStop;
      } else {
        break;
      }
    }

    return columns;
  }

  int? _indentFoldEnd(int lineIndex, String line) {
    final startIndent = _measureLeadingIndentColumns(line);
    var endLine = lineIndex;
    for (var j = lineIndex + 1; j < controller.lineCount; j++) {
      final next = controller.getLineText(j);
      if (next.trim().isEmpty) continue;
      if (_measureLeadingIndentColumns(next) <= startIndent) break;
      endLine = j;
    }
    return endLine > lineIndex ? endLine : null;
  }

  FoldRange? _getOrComputeFoldRange(int lineIndex) {
    if (_foldRanges.containsKey(lineIndex)) {
      return _foldRanges[lineIndex];
    }

    if (!_foldsInBackground) {
      final fold = _computeFoldRangeForLine(lineIndex);
      _foldRanges[lineIndex] = fold;
      return fold;
    }

    // Lines the whole-document pass found no fold at stay absent from
    // _foldRanges, so only a newer document may schedule another pass.
    if (!_asyncFoldComputationPending &&
        _asyncFoldsVersion != controller.contentVersion) {
      _scheduleAsyncFoldComputation();
    }
    return null;
  }

  /// False when the text no longer gives [fold] a range to fold.
  bool _toggleFold(FoldRange fold) {
    final current = fold.isFolded ? fold : _currentFold(fold);
    if (current == null) {
      markNeedsPaint();
      return false;
    }
    _isFoldToggleInProgress = true;
    if (current.isFolded) {
      _unfoldWithChildren(current);
    } else {
      _foldWithChildren(current);
      _moveSelectionOutOf(current);
    }
    _commitFoldChange();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isFoldToggleInProgress = false;
      _clampScrollAfterFold();
    });
    return true;
  }

  void _moveSelectionOutOf(FoldRange fold) {
    bool hides(int offset) {
      final line = controller.getLineAtOffset(offset);
      return line > fold.startIndex && line <= fold.endIndex;
    }

    final selection = controller.selection;
    if (!hides(selection.baseOffset) && !hides(selection.extentOffset)) return;
    controller.selection = TextSelection.collapsed(
      offset:
          controller.getLineStartOffset(fold.startIndex) +
          controller.getLineText(fold.startIndex).runes.length,
    );
  }

  bool _unfoldAround(int line) {
    FoldRange? hiding() => _foldRanges.values.nonNulls
        .where(
          (fold) =>
              fold.isFolded && line > fold.startIndex && line <= fold.endIndex,
        )
        .firstOrNull;
    var fold = hiding();
    if (fold == null) return false;
    for (; fold != null; fold = hiding()) {
      _unfoldWithChildren(fold);
    }
    _commitFoldChange();
    return true;
  }

  void _revealCaret() {
    final selection = controller.selection;
    if (!selection.isCollapsed) return;
    final line = controller.getLineAtOffset(selection.extentOffset);
    if (controller.isLineInFoldedRegion(line)) _unfoldAround(line);
  }

  // An edit inside an unfolded fold leaves its cached range as it was.
  FoldRange? _currentFold(FoldRange fold) {
    if (_foldsInBackground) return fold;
    final current = _computeFoldRangeForLine(fold.startIndex);
    if (current == fold) return fold;
    return _foldRanges[fold.startIndex] = current;
  }

  void _commitFoldChange() {
    controller.foldings = {
      for (final fold in _foldRanges.values.nonNulls) fold.startIndex: fold,
    };
    _foldedLineCacheDirty = true;
    _foldLayoutPending = true;
    _invalidateCaret();
    markNeedsLayout();
    markNeedsPaint();
  }

  void _toggleFoldAtLine(int lineNumber) {
    if (lineNumber < 0 || lineNumber >= controller.lineCount) return;

    final foldRange = _getFoldRangeAtLine(lineNumber);
    if (foldRange != null && foldRange.endIndex > foldRange.startIndex) {
      _toggleFold(foldRange);
    }
  }

  void _clampScrollAfterFold() {
    if (!vscrollController.hasClients) return;
    final maxExtent = vscrollController.position.maxScrollExtent;
    if (vscrollController.offset > maxExtent) {
      vscrollController.jumpTo(maxExtent.clamp(0.0, double.infinity));
    }
  }

  void _foldWithChildren(FoldRange parentFold) {
    parentFold.originallyFoldedChildren = [
      for (final childFold in _foldRanges.values.nonNulls)
        if (childFold.isFolded &&
            childFold != parentFold &&
            childFold.startIndex > parentFold.startIndex &&
            childFold.endIndex <= parentFold.endIndex)
          childFold..isFolded = false,
    ];
    parentFold.isFolded = true;
  }

  void _unfoldWithChildren(FoldRange parentFold) {
    parentFold.isFolded = false;
    for (final childFold in parentFold.originallyFoldedChildren) {
      if (childFold.startIndex > parentFold.startIndex &&
          childFold.endIndex <= parentFold.endIndex &&
          identical(_currentFold(childFold), childFold)) {
        _foldRanges[childFold.startIndex] = childFold..isFolded = true;
      }
    }
    parentFold.originallyFoldedChildren = [];
  }

  bool _isLineFolded(int lineIndex) => _lines.isHidden(lineIndex);

  int? _findMatchingBracket(int pos) {
    if (_bracketCache.containsKey(pos)) {
      return _bracketCache[pos];
    }

    if (pos < 0 || pos >= controller.rope.length) {
      _bracketCache[pos] = null;
      return null;
    }

    final result = foldsFindMatchingBracket(
      rope: controller.rope.core,
      targetOffset: BigInt.from(pos),
    )?.toInt();

    _bracketCache[pos] = result;
    return result;
  }

  FoldRange? _getFoldRangeAtLine(int lineIndex) =>
      _getOrComputeFoldRange(lineIndex);
}

extension on FoldRange {
  FoldRange _moved(int start, int end) => start == startIndex && end == endIndex
      ? this
      : (FoldRange(start, end)
          ..isFolded = isFolded
          ..originallyFoldedChildren = originallyFoldedChildren);
}
