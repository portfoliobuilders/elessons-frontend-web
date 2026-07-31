// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

StreamSubscription<html.MouseEvent>? _contextMenuSub;
StreamSubscription<html.MouseEvent>? _dragStartSub;
StreamSubscription<html.KeyboardEvent>? _keySub;

/// Dynamically injects context menu blocking, user-select restrictions, and keyboard shortcut shields on Flutter Web.
void setupWebSecurityShield() {
  if (!kIsWeb) return;

  try {
    // 1. Inject CSS rules to prevent text selection and element dragging
    final html.StyleElement style = html.StyleElement()
      ..id = 'gtec-web-security-styles'
      ..type = 'text/css'
      ..innerHtml = '''
        * {
          -webkit-user-select: none !important;
          -moz-user-select: none !important;
          -ms-user-select: none !important;
          user-select: none !important;
          -webkit-user-drag: none !important;
          user-drag: none !important;
        }
        iframe, canvas, video {
          pointer-events: auto;
          -webkit-touch-callout: none !important;
        }
      ''';
    if (html.document.head != null && html.document.querySelector('#gtec-web-security-styles') == null) {
      html.document.head!.append(style);
    }

    // 2. Prevent right-click / context menu on entire document
    _contextMenuSub ??= html.document.onContextMenu.listen((html.MouseEvent e) {
      e.preventDefault();
      e.stopPropagation();
    });

    // 3. Prevent dragging iframe/elements out
    _dragStartSub ??= html.document.onDragStart.listen((html.MouseEvent e) {
      e.preventDefault();
      e.stopPropagation();
    });

    // 4. Block common inspect/save hotkeys (F12, Ctrl+U, Ctrl+S, Ctrl+Shift+I, Cmd+Option+I)
    _keySub ??= html.window.onKeyDown.listen((html.KeyboardEvent e) {
      final bool ctrlOrCmd = e.ctrlKey || e.metaKey;
      if (e.keyCode == 123 || // F12
          (ctrlOrCmd && e.keyCode == 85) || // Ctrl+U (View Source)
          (ctrlOrCmd && e.keyCode == 83) || // Ctrl+S (Save Page)
          (ctrlOrCmd && e.shiftKey && e.keyCode == 73) || // Ctrl+Shift+I (DevTools)
          (ctrlOrCmd && e.shiftKey && e.keyCode == 67) || // Ctrl+Shift+C (Inspect Element)
          (ctrlOrCmd && e.shiftKey && e.keyCode == 74)) { // Ctrl+Shift+J (Console)
        e.preventDefault();
        e.stopPropagation();
      }
    });

    debugPrint('🔒 [WebSecurityShield]: Web DOM protection & right-click block activated.');
  } catch (e) {
    debugPrint('⚠️ [WebSecurityShield]: Could not initialize web DOM protection: $e');
  }
}

/// Cleans up web listeners when navigating away if necessary.
void cleanupWebSecurityShield() {
  if (!kIsWeb) return;
  _contextMenuSub?.cancel();
  _contextMenuSub = null;
  _dragStartSub?.cancel();
  _dragStartSub = null;
  _keySub?.cancel();
  _keySub = null;
}
