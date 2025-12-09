import 'package:flutter/material.dart';

import '../enums/otp_field_style.dart';
import '../otp_theme.dart';

/// Internal utility for building [InputDecoration] based on field style and state.
///
/// This class is used internally by [OTPTextField] to create appropriate
/// decorations for different [OTPFieldStyle] options and field states.
///
/// You typically don't need to use this class directly. Instead, use
/// [OTPTextField] with the [OTPTextField.fieldStyle] and [OTPTextField.theme]
/// parameters.
///
class FieldDecorationBuilder {
  /// Builds [InputDecoration] based on the field style and current state.
  ///
  /// The decoration adapts based on:
  /// - [fieldStyle]: The visual style (box, underline, or circle)
  /// - [theme]: Theme configuration for colors and dimensions
  /// - [isFocused]: Whether the field currently has focus
  /// - [hasError]: Whether to display error state
  /// - [enabled]: Whether the field is enabled for input
  /// - [fieldWidth]: Width of the field (used for circle style)
  static InputDecoration build({
    required OTPFieldStyle fieldStyle,
    required OTPTheme theme,
    required bool isFocused,
    required bool hasError,
    required bool enabled,
    double? fieldWidth,
  }) {
    switch (fieldStyle) {
      case OTPFieldStyle.box:
        return _buildBoxDecoration(
          theme: theme,
          isFocused: isFocused,
          hasError: hasError,
          enabled: enabled,
        );
      case OTPFieldStyle.underline:
        return _buildUnderlineDecoration(
          theme: theme,
          isFocused: isFocused,
          hasError: hasError,
          enabled: enabled,
        );
      case OTPFieldStyle.circle:
        return _buildCircleDecoration(
          theme: theme,
          isFocused: isFocused,
          hasError: hasError,
          enabled: enabled,
          fieldWidth: fieldWidth,
        );
    }
  }

  /// Build box-style decoration (default)
  static InputDecoration _buildBoxDecoration({
    required OTPTheme theme,
    required bool isFocused,
    required bool hasError,
    required bool enabled,
  }) {
    final borderColor = _getBorderColor(
      theme: theme,
      isFocused: isFocused,
      hasError: hasError,
      enabled: enabled,
    );
    final borderWidth = _getBorderWidth(
      theme: theme,
      isFocused: isFocused,
      hasError: hasError,
    );
    final fillColor = _getFillColor(theme: theme, enabled: enabled);

    return InputDecoration(
      counterText: '',
      filled: fillColor != null,
      fillColor: fillColor,
      contentPadding: theme.contentPadding,
      border: OutlineInputBorder(
        borderRadius: theme.borderRadius,
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: theme.borderRadius,
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: theme.borderRadius,
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: theme.borderRadius,
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
    );
  }

  /// Build underline-style decoration
  static InputDecoration _buildUnderlineDecoration({
    required OTPTheme theme,
    required bool isFocused,
    required bool hasError,
    required bool enabled,
  }) {
    final borderColor = _getBorderColor(
      theme: theme,
      isFocused: isFocused,
      hasError: hasError,
      enabled: enabled,
    );
    final borderWidth = hasError
        ? theme.errorBorderWidth
        : (isFocused ? theme.underlineWidth : theme.borderWidth);
    final fillColor = _getFillColor(theme: theme, enabled: enabled);

    return InputDecoration(
      counterText: '',
      filled: fillColor != null,
      fillColor: fillColor,
      contentPadding: theme.contentPadding,
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
    );
  }

  /// Build circle-style decoration
  static InputDecoration _buildCircleDecoration({
    required OTPTheme theme,
    required bool isFocused,
    required bool hasError,
    required bool enabled,
    double? fieldWidth,
  }) {
    final borderColor = _getBorderColor(
      theme: theme,
      isFocused: isFocused,
      hasError: hasError,
      enabled: enabled,
    );
    final borderWidth = _getBorderWidth(
      theme: theme,
      isFocused: isFocused,
      hasError: hasError,
    );
    final fillColor = _getFillColor(theme: theme, enabled: enabled);

    // Calculate circular border radius based on field width
    final circularRadius = fieldWidth != null
        ? Radius.circular(fieldWidth / 2)
        : const Radius.circular(25);

    return InputDecoration(
      counterText: '',
      filled: fillColor != null,
      fillColor: fillColor,
      contentPadding: theme.contentPadding,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(circularRadius),
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(circularRadius),
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(circularRadius),
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(circularRadius),
        borderSide: BorderSide(color: borderColor, width: borderWidth),
      ),
    );
  }

  /// Get border color based on current state
  static Color _getBorderColor({
    required OTPTheme theme,
    required bool isFocused,
    required bool hasError,
    required bool enabled,
  }) {
    if (!enabled) {
      return theme.disabledBorderColor ?? theme.borderColor;
    }
    if (hasError) {
      return theme.errorBorderColor ?? theme.borderColor;
    }
    if (isFocused) {
      return theme.focusedBorderColor;
    }
    return theme.borderColor;
  }

  /// Get border width based on current state
  static double _getBorderWidth({
    required OTPTheme theme,
    required bool isFocused,
    required bool hasError,
  }) {
    if (hasError) {
      return theme.errorBorderWidth;
    }
    if (isFocused) {
      return theme.focusedBorderWidth;
    }
    return theme.borderWidth;
  }

  /// Get fill color based on enabled state
  static Color? _getFillColor({
    required OTPTheme theme,
    required bool enabled,
  }) {
    if (!enabled) {
      return theme.disabledFillColor ?? theme.fillColor;
    }
    return theme.fillColor;
  }
}
