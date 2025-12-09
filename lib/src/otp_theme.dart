import 'package:flutter/material.dart';

/// Theme configuration for OTP text field styling.
///
/// Provides comprehensive styling options for OTP fields including borders,
/// fills, cursors, and state-specific appearances.
///
/// ## Usage
///
/// Use preset themes for quick setup:
/// ```dart
/// OTPTextField(
///   theme: OTPTheme.light(), // or OTPTheme.dark()
/// )
/// ```
///
/// Or create custom themes:
/// ```dart
/// OTPTextField(
///   theme: OTPTheme.custom(
///     borderColor: Colors.grey,
///     focusedBorderColor: Colors.blue,
///     errorBorderColor: Colors.red,
///     fillColor: Colors.white,
///     borderRadius: BorderRadius.circular(12),
///   ),
/// )
/// ```
///
/// Modify existing themes using [copyWith]:
/// ```dart
/// final customTheme = OTPTheme.light().copyWith(
///   borderColor: Colors.purple,
///   focusedBorderColor: Colors.deepPurple,
/// );
/// ```
///
/// See also:
/// - [OTPTextField] for the main widget using this theme
/// - [light] for light theme preset
/// - [dark] for dark theme preset
/// - [custom] for creating custom themes
class OTPTheme {
  /// Border color for inactive (unfocused) fields.
  ///
  /// This color is used when the field is neither focused nor in an error state.
  final Color borderColor;

  /// Border color for the currently focused field.
  ///
  /// Applied when a field receives keyboard focus.
  final Color focusedBorderColor;

  /// Border color when [OTPTextField.hasError] is true.
  ///
  /// If null, falls back to [borderColor].
  final Color? errorBorderColor;

  /// Border width when [OTPTextField.hasError] is true.
  ///
  /// Defaults to 2.0.
  final double errorBorderWidth;

  /// Background fill color for the fields.
  ///
  /// If null, fields have no background fill.
  final Color? fillColor;

  /// Border color when [OTPTextField.enabled] is false.
  ///
  /// If null, uses [borderColor] with reduced opacity.
  final Color? disabledBorderColor;

  /// Background fill color when [OTPTextField.enabled] is false.
  ///
  /// If null, uses [fillColor] with reduced opacity.
  final Color? disabledFillColor;

  /// Border width for inactive fields.
  ///
  /// Defaults to 1.5.
  final double borderWidth;

  /// Border width for the focused field.
  ///
  /// Defaults to 2.0.
  final double focusedBorderWidth;

  /// Corner radius for field boxes.
  ///
  /// Only applies to [OTPFieldStyle.box] and [OTPFieldStyle.circle].
  /// For circles, this is overridden to create a circular shape.
  ///
  /// Defaults to 8.0 pixels on all corners.
  final BorderRadius borderRadius;

  /// Line width for [OTPFieldStyle.underline] style.
  ///
  /// Defaults to 2.0.
  final double underlineWidth;

  /// Whether to show the text cursor.
  ///
  /// Defaults to true.
  final bool showCursor;

  /// Color of the text cursor.
  ///
  /// If null, uses the theme's primary color.
  final Color? cursorColor;

  /// Height of the text cursor in logical pixels.
  ///
  /// If null, uses the default cursor height.
  final double? cursorHeight;

  /// Width of the text cursor in logical pixels.
  ///
  /// Defaults to 2.0.
  final double cursorWidth;

  /// Color of the text selection (highlight color when text is selected/dragged).
  ///
  /// If null, uses the theme's default selection color.
  final Color? selectionColor;

  /// Color of the text selection handles.
  ///
  /// If null, uses the theme's default selection handle color.
  final Color? selectionHandleColor;

  const OTPTheme({
    required this.borderColor,
    required this.focusedBorderColor,
    this.errorBorderColor,
    this.errorBorderWidth = 2.0,
    this.fillColor,
    this.disabledBorderColor,
    this.disabledFillColor,
    this.borderWidth = 1.5,
    this.focusedBorderWidth = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.underlineWidth = 2.0,
    this.showCursor = true,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth = 2.0,
    this.selectionColor,
    this.selectionHandleColor,
  });

  /// Creates a light theme preset optimized for light backgrounds.
  ///
  /// Uses light gray borders and white fills by default. All parameters
  /// are optional and can be overridden.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   theme: OTPTheme.light(
  ///     focusedBorderColor: Colors.blue,
  ///   ),
  /// )
  /// ```
  ///
  /// See also:
  /// - [dark] for dark theme preset
  /// - [custom] for full customization
  static OTPTheme light({
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    Color? fillColor,
    Color? disabledBorderColor,
    Color? disabledFillColor,
  }) {
    return OTPTheme(
      borderColor: borderColor ?? Colors.grey.shade400,
      focusedBorderColor: focusedBorderColor ?? Colors.blue,
      errorBorderColor: errorBorderColor ?? Colors.red,
      fillColor: fillColor ?? Colors.white,
      disabledBorderColor: disabledBorderColor ?? Colors.grey.shade300,
      disabledFillColor: disabledFillColor ?? Colors.grey.shade100,
    );
  }

  /// Creates a dark theme preset optimized for dark backgrounds.
  ///
  /// Uses dark gray borders and dark fills by default. All parameters
  /// are optional and can be overridden.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   theme: OTPTheme.dark(
  ///     focusedBorderColor: Colors.blueAccent,
  ///   ),
  /// )
  /// ```
  ///
  /// See also:
  /// - [light] for light theme preset
  /// - [custom] for full customization
  static OTPTheme dark({
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    Color? fillColor,
    Color? disabledBorderColor,
    Color? disabledFillColor,
  }) {
    return OTPTheme(
      borderColor: borderColor ?? Colors.grey.shade700,
      focusedBorderColor: focusedBorderColor ?? Colors.blueAccent,
      errorBorderColor: errorBorderColor ?? Colors.redAccent,
      fillColor: fillColor ?? Colors.grey.shade900,
      disabledBorderColor: disabledBorderColor ?? Colors.grey.shade800,
      disabledFillColor: disabledFillColor ?? Colors.grey.shade800,
    );
  }

  /// Creates a fully customizable theme.
  ///
  /// Requires [borderColor] and [focusedBorderColor] to be provided.
  /// All other parameters are optional.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   theme: OTPTheme.custom(
  ///     borderColor: Colors.purple.shade300,
  ///     focusedBorderColor: Colors.purple,
  ///     errorBorderColor: Colors.orange,
  ///     fillColor: Colors.purple.shade50,
  ///     borderRadius: BorderRadius.circular(12),
  ///     underlineWidth: 3.0,
  ///   ),
  /// )
  /// ```
  ///
  /// See also:
  /// - [light] for a light theme preset
  /// - [dark] for a dark theme preset
  static OTPTheme custom({
    required Color borderColor,
    required Color focusedBorderColor,
    Color? errorBorderColor,
    double errorBorderWidth = 2.0,
    Color? fillColor,
    Color? disabledBorderColor,
    Color? disabledFillColor,
    double borderWidth = 1.5,
    double focusedBorderWidth = 2.0,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(8)),
    double underlineWidth = 2.0,
    bool showCursor = true,
    Color? cursorColor,
    double? cursorHeight,
    double cursorWidth = 2.0,
    Color? selectionColor,
    Color? selectionHandleColor,
  }) {
    return OTPTheme(
      borderColor: borderColor,
      focusedBorderColor: focusedBorderColor,
      errorBorderColor: errorBorderColor,
      errorBorderWidth: errorBorderWidth,
      fillColor: fillColor,
      disabledBorderColor: disabledBorderColor,
      disabledFillColor: disabledFillColor,
      borderWidth: borderWidth,
      focusedBorderWidth: focusedBorderWidth,
      borderRadius: borderRadius,
      underlineWidth: underlineWidth,
      showCursor: showCursor,
      cursorColor: cursorColor,
      cursorHeight: cursorHeight,
      cursorWidth: cursorWidth,
      selectionColor: selectionColor,
      selectionHandleColor: selectionHandleColor,
    );
  }

  /// Creates a copy of this theme with the given fields replaced.
  ///
  /// Useful for modifying preset themes or creating theme variations.
  /// Any parameter not provided will keep its current value.
  ///
  /// Example:
  /// ```dart
  /// final baseTheme = OTPTheme.light();
  /// final customTheme = baseTheme.copyWith(
  ///   focusedBorderColor: Colors.green,
  ///   borderRadius: BorderRadius.circular(16),
  /// );
  /// ```
  OTPTheme copyWith({
    Color? borderColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    double? errorBorderWidth,
    Color? fillColor,
    Color? disabledBorderColor,
    Color? disabledFillColor,
    double? borderWidth,
    double? focusedBorderWidth,
    BorderRadius? borderRadius,
    double? underlineWidth,
    bool? showCursor,
    Color? cursorColor,
    double? cursorHeight,
    double? cursorWidth,
    Color? selectionColor,
    Color? selectionHandleColor,
  }) {
    return OTPTheme(
      borderColor: borderColor ?? this.borderColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      errorBorderWidth: errorBorderWidth ?? this.errorBorderWidth,
      fillColor: fillColor ?? this.fillColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      disabledFillColor: disabledFillColor ?? this.disabledFillColor,
      borderWidth: borderWidth ?? this.borderWidth,
      focusedBorderWidth: focusedBorderWidth ?? this.focusedBorderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      underlineWidth: underlineWidth ?? this.underlineWidth,
      showCursor: showCursor ?? this.showCursor,
      cursorColor: cursorColor ?? this.cursorColor,
      cursorHeight: cursorHeight ?? this.cursorHeight,
      cursorWidth: cursorWidth ?? this.cursorWidth,
      selectionColor: selectionColor ?? this.selectionColor,
      selectionHandleColor: selectionHandleColor ?? this.selectionHandleColor,
    );
  }
}
