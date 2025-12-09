import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'enums/otp_field_style.dart';
import 'enums/otp_input_type.dart';
import 'otp_theme.dart';
import 'styles/field_decoration_builder.dart';

/// A customizable OTP (One-Time Password) text field widget.
///
/// This widget creates multiple text fields for entering OTP codes with
/// various styling options, automatic focus management, and keyboard navigation.
///
/// ## Basic Usage
///
/// ```dart
/// final controllers = List.generate(6, (_) => TextEditingController());
/// final focusNodes = List.generate(6, (_) => FocusNode());
///
/// OTPTextField(
///   controllers: controllers,
///   focusNodes: focusNodes,
///   textStyle: TextStyle(fontSize: 24),
///   onCompleted: (otp) => print('OTP: $otp'),
/// )
/// ```
///
/// ## Styling Options
///
/// The widget supports multiple visual styles through [fieldStyle]:
/// - [OTPFieldStyle.box] - Box-shaped fields (default)
/// - [OTPFieldStyle.underline] - Underlined fields
/// - [OTPFieldStyle.circle] - Circular fields
///
/// ## Input Types
///
/// Control what characters are allowed via [inputType]:
/// - [OTPInputType.number] - Only numeric digits (default)
/// - [OTPInputType.text] - Only alphabetic characters
/// - [OTPInputType.any] - Both numbers and letters
///
/// ## Theming
///
/// Customize appearance using [theme] or let it automatically adapt
/// to the current [ThemeData.brightness]:
///
/// ```dart
/// OTPTextField(
///   theme: OTPTheme.custom(
///     borderColor: Colors.blue,
///     focusedBorderColor: Colors.blueAccent,
///   ),
/// )
/// ```
///
/// See also:
/// - [OTPTheme] for detailed theming options
/// - [OTPFieldStyle] for available visual styles
/// - [OTPInputType] for input type options
class OTPTextField extends StatefulWidget {
  /// The list of text controllers for each OTP field.
  ///
  /// Must have the same length as [focusNodes]. You are responsible for
  /// creating and disposing these controllers.
  ///
  /// Example:
  /// ```dart
  /// final controllers = List.generate(6, (_) => TextEditingController());
  /// // ... use in widget
  /// // Don't forget to dispose:
  /// @override
  /// void dispose() {
  ///   for (var controller in controllers) {
  ///     controller.dispose();
  ///   }
  ///   super.dispose();
  /// }
  /// ```
  final List<TextEditingController> controllers;

  /// The list of focus nodes for each OTP field.
  ///
  /// Must have the same length as [controllers]. Used for managing keyboard
  /// focus and navigation between fields.
  ///
  /// Example:
  /// ```dart
  /// final focusNodes = List.generate(6, (_) => FocusNode());
  /// // ... use in widget
  /// // Don't forget to dispose:
  /// @override
  /// void dispose() {
  ///   for (var node in focusNodes) {
  ///     node.dispose();
  ///   }
  ///   super.dispose();
  /// }
  /// ```
  final List<FocusNode> focusNodes;

  /// Callback invoked when all OTP fields are filled.
  ///
  /// The callback receives the complete OTP string as a parameter.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   onCompleted: (otp) {
  ///     print('Complete OTP: $otp');
  ///     // Verify OTP
  ///   },
  /// )
  /// ```
  final ValueChanged<String>? onCompleted;

  /// Callback invoked whenever any field value changes.
  ///
  /// The callback receives the current (possibly incomplete) OTP string.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   onChange: (currentOtp) {
  ///     print('Current value: $currentOtp');
  ///     setState(() => _otp = currentOtp);
  ///   },
  /// )
  /// ```
  final ValueChanged<String>? onChange;

  /// The width of each OTP field.
  ///
  /// Defaults to 40.0 logical pixels.
  final double fieldWidth;

  /// The height of each OTP field.
  ///
  /// Defaults to 50.0 logical pixels.
  final double fieldHeight;

  /// The spacing between adjacent OTP fields.
  ///
  /// Defaults to 8.0 logical pixels. This spacing is applied between
  /// all fields except where [centerSpacing] is used.
  ///
  /// See also:
  /// - [centerSpacing] for adding extra space in the middle
  final double fieldSpacing;

  /// Extra spacing applied at the middle of the OTP fields.
  ///
  /// When not null, adds extra space at the middle index (length / 2).
  /// This is commonly used for 6-digit OTPs to group them as "XXX XXX".
  ///
  /// - For 6 fields: spacing between 3rd and 4th field
  /// - For 4 fields: spacing between 2nd and 3rd field
  /// - If null, uniform [fieldSpacing] is used throughout
  ///
  /// Example:
  /// ```dart
  /// // Create "123 456" layout
  /// OTPTextField(
  ///   controllers: controllers, // length 6
  ///   focusNodes: focusNodes,
  ///   centerSpacing: 16,
  /// )
  /// ```
  final double? centerSpacing;

  /// The text style applied to the input text.
  ///
  /// This is a required parameter. The style is modified when the field
  /// is disabled (opacity reduced to 0.5).
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   textStyle: TextStyle(
  ///     fontSize: 24,
  ///     fontWeight: FontWeight.bold,
  ///     color: Colors.black,
  ///   ),
  /// )
  /// ```
  final TextStyle textStyle;

  /// The theme configuration for styling the OTP fields.
  ///
  /// If null, automatically uses [OTPTheme.light] or [OTPTheme.dark]
  /// based on the current [ThemeData.brightness].
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   theme: OTPTheme.custom(
  ///     borderColor: Colors.grey,
  ///     focusedBorderColor: Colors.blue,
  ///     errorBorderColor: Colors.red,
  ///     fillColor: Colors.white,
  ///   ),
  /// )
  /// ```
  ///
  /// See also:
  /// - [OTPTheme.light] for light theme preset
  /// - [OTPTheme.dark] for dark theme preset
  /// - [OTPTheme.custom] for custom themes
  final OTPTheme? theme;

  /// The visual style of the OTP fields.
  ///
  /// Defaults to [OTPFieldStyle.box].
  ///
  /// Available styles:
  /// - [OTPFieldStyle.box] - Box with borders on all sides
  /// - [OTPFieldStyle.underline] - Only bottom border
  /// - [OTPFieldStyle.circle] - Circular fields
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   fieldStyle: OTPFieldStyle.underline,
  /// )
  /// ```
  final OTPFieldStyle fieldStyle;

  /// The type of input allowed in the OTP fields.
  ///
  /// Defaults to [OTPInputType.number].
  ///
  /// Options:
  /// - [OTPInputType.number] - Only numeric digits (0-9)
  /// - [OTPInputType.text] - Only alphabetic characters (a-z, A-Z)
  /// - [OTPInputType.any] - Both numbers and letters
  ///
  /// The keyboard type is automatically set based on this value unless
  /// [keyboardType] is explicitly provided.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   inputType: OTPInputType.text,
  ///   textCapitalization: TextCapitalization.characters,
  /// )
  /// ```
  final OTPInputType inputType;

  /// Whether to obscure the text being entered.
  ///
  /// When true, entered characters are hidden using [obscuringCharacter].
  /// Useful for secure PIN entry.
  ///
  /// Defaults to false.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   obscureText: true,
  ///   obscuringCharacter: '●',
  /// )
  /// ```
  final bool obscureText;

  /// The character used to obscure text when [obscureText] is true.
  ///
  /// Must be exactly one character. Defaults to '●'.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   obscureText: true,
  ///   obscuringCharacter: '*',
  /// )
  /// ```
  final String obscuringCharacter;

  /// Whether the text fields are enabled for input.
  ///
  /// When false, the fields are disabled and displayed with reduced opacity.
  /// Keyboard navigation is also disabled.
  ///
  /// Defaults to true.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   enabled: !isLoading,
  /// )
  /// ```
  final bool enabled;

  /// Whether to automatically focus the first field when the widget is built.
  ///
  /// Defaults to false.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   autoFocus: true, // First field receives focus immediately
  /// )
  /// ```
  final bool autoFocus;

  /// Whether to display the error state styling.
  ///
  /// When true, fields are styled with [OTPTheme.errorBorderColor] and
  /// [OTPTheme.errorBorderWidth].
  ///
  /// Defaults to false.
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   hasError: otpIncorrect,
  ///   theme: OTPTheme.light().copyWith(
  ///     errorBorderColor: Colors.red,
  ///   ),
  /// )
  /// ```
  final bool hasError;

  /// Overrides the cursor visibility.
  ///
  /// If null, uses the value from [theme]. If [theme] is also null,
  /// uses the theme's default.
  final bool? showCursor;

  /// Overrides the cursor color.
  ///
  /// If null, uses the value from [theme]. If [theme] is also null,
  /// uses the theme's default.
  final Color? cursorColor;

  /// Overrides the cursor height in logical pixels.
  ///
  /// If null, uses the value from [theme]. If [theme] is also null,
  /// uses the theme's default.
  final double? cursorHeight;

  /// Overrides the cursor width in logical pixels.
  ///
  /// If null, uses the value from [theme]. If [theme] is also null,
  /// uses 2.0.
  final double? cursorWidth;

  /// Overrides the text selection color (highlight color when text is selected).
  ///
  /// If null, uses the value from [theme]. If [theme] is also null,
  /// uses the theme's default selection color.
  final Color? selectionColor;

  /// Overrides the text selection handle color.
  ///
  /// If null, uses the value from [theme]. If [theme] is also null,
  /// uses the theme's default selection handle color.
  final Color? selectionHandleColor;

  /// Configures how the text input should be capitalized.
  ///
  /// Only affects [OTPInputType.text] and [OTPInputType.any].
  ///
  /// Defaults to [TextCapitalization.none].
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   inputType: OTPInputType.text,
  ///   textCapitalization: TextCapitalization.characters, // A-Z
  /// )
  /// ```
  final TextCapitalization textCapitalization;

  /// Overrides the keyboard type to show.
  ///
  /// If null, the keyboard type is determined by [inputType]:
  /// - [OTPInputType.number] → [TextInputType.number]
  /// - [OTPInputType.text] or [OTPInputType.any] → [TextInputType.text]
  ///
  /// Example:
  /// ```dart
  /// OTPTextField(
  ///   keyboardType: TextInputType.phone, // Show phone keyboard
  /// )
  /// ```
  final TextInputType? keyboardType;

  const OTPTextField({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.textStyle,
    this.onCompleted,
    this.onChange,
    this.fieldWidth = 40,
    this.fieldHeight = 50,
    this.fieldSpacing = 8,
    this.centerSpacing,
    this.theme,
    this.fieldStyle = OTPFieldStyle.box,
    this.inputType = OTPInputType.number,
    this.obscureText = false,
    this.obscuringCharacter = '●',
    this.enabled = true,
    this.autoFocus = false,
    this.hasError = false,
    this.showCursor,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth,
    this.selectionColor,
    this.selectionHandleColor,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
  }) : assert(
         controllers.length == focusNodes.length,
         'Controllers and FocusNodes must have the same length',
       ),
       assert(
         obscuringCharacter.length == 1,
         'obscuringCharacter must be a single character',
       );

  @override
  State<OTPTextField> createState() => _OTPTextFieldState();
}

class _OTPTextFieldState extends State<OTPTextField> {
  late OTPTheme _theme;

  @override
  void initState() {
    super.initState();

    // Auto-focus first field if enabled
    if (widget.autoFocus && widget.controllers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.controllers[0].text.isEmpty && widget.enabled) {
          widget.focusNodes[0].requestFocus();
        }
      });
    }

    // Add focus listeners to trigger rebuilds for decoration
    for (final focusNode in widget.focusNodes) {
      focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    // Remove focus listeners
    for (final focusNode in widget.focusNodes) {
      focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _theme = widget.theme ?? _getDefaultTheme();
  }

  @override
  void didUpdateWidget(OTPTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme != oldWidget.theme) {
      _theme = widget.theme ?? _getDefaultTheme();
    }
  }

  void _onFocusChange() {
    // Trigger rebuild when focus changes
    setState(() {});
  }

  OTPTheme _getDefaultTheme() {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? OTPTheme.dark() : OTPTheme.light();
  }

  void _onTextChanged(int index, String text) {
    // Call onChange callback whenever value changes
    if (widget.onChange != null) {
      final fullText = widget.controllers.map((c) => c.text).join();
      widget.onChange!(fullText);
    }

    // Check if all fields are filled
    final otp = widget.controllers.map((c) => c.text).join();
    final isAllFilled = otp.length == widget.controllers.length;

    if (text.isNotEmpty) {
      // If all fields are filled, call completion callback
      if (isAllFilled) {
        if (widget.onCompleted != null) {
          widget.onCompleted!(otp);
        }
        // Unfocus if it's the last field
        if (index == widget.controllers.length - 1) {
          widget.focusNodes[index].unfocus();
        }
      } else {
        // Move focus to next empty field
        if (index < widget.controllers.length - 1) {
          widget.focusNodes[index + 1].requestFocus();
        }
      }
    }
  }

  /// Get input formatters based on input type
  List<TextInputFormatter> _getInputFormatters() {
    switch (widget.inputType) {
      case OTPInputType.number:
        return [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ];
      case OTPInputType.text:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
          LengthLimitingTextInputFormatter(1),
        ];
      case OTPInputType.any:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
          LengthLimitingTextInputFormatter(1),
        ];
    }
  }

  /// Get keyboard type based on input type or override
  TextInputType _getKeyboardType() {
    if (widget.keyboardType != null) {
      return widget.keyboardType!;
    }

    switch (widget.inputType) {
      case OTPInputType.number:
        return TextInputType.number;
      case OTPInputType.text:
      case OTPInputType.any:
        return TextInputType.text;
    }
  }

  /// Build decoration for a field based on its state
  InputDecoration _buildDecoration(int index) {
    final isFocused = widget.focusNodes[index].hasFocus;

    return FieldDecorationBuilder.build(
      fieldStyle: widget.fieldStyle,
      theme: _theme,
      isFocused: isFocused,
      hasError: widget.hasError,
      enabled: widget.enabled,
      fieldWidth: widget.fieldWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.controllers.length, (index) {
        // Add extra spacing in the middle if centerSpacing is provided
        final middleIndex = widget.controllers.length ~/ 2;
        final isMiddleGap =
            widget.centerSpacing != null && index == middleIndex;
        final leftMargin = isMiddleGap
            ? widget.centerSpacing!
            : widget.fieldSpacing / 2;

        return Container(
          margin: EdgeInsets.only(
            left: leftMargin,
            right: widget.fieldSpacing / 2,
          ),
          width: widget.fieldWidth,
          height: widget.fieldHeight,
          child: Focus(
            onKeyEvent: (node, event) {
              if (!widget.enabled) {
                return KeyEventResult.ignored;
              }

              // Only handle key down events (ignore released)
              if (event is KeyDownEvent) {
                final controller = widget.controllers[index];

                // Handle backspace
                if (event.logicalKey == LogicalKeyboardKey.backspace) {
                  if (controller.text.isEmpty && index > 0) {
                    // If current field is empty and not first, move to previous field
                    widget.focusNodes[index - 1].requestFocus();
                    widget.controllers[index - 1].clear();
                    return KeyEventResult.handled;
                  }
                }
                // Left arrow: move to previous field
                else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                  if (index > 0) {
                    widget.focusNodes[index - 1].requestFocus();
                    // Move cursor to end
                    widget.controllers[index - 1].selection =
                        TextSelection.fromPosition(
                          TextPosition(
                            offset: widget.controllers[index - 1].text.length,
                          ),
                        );
                    return KeyEventResult.handled;
                  }
                }
                // Right arrow: move to next field
                else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                  if (index < widget.controllers.length - 1) {
                    widget.focusNodes[index + 1].requestFocus();
                    // Move cursor to end
                    widget.controllers[index + 1].selection =
                        TextSelection.fromPosition(
                          TextPosition(
                            offset: widget.controllers[index + 1].text.length,
                          ),
                        );
                    return KeyEventResult.handled;
                  }
                }
                // Tab: move to next field
                else if (event.logicalKey == LogicalKeyboardKey.tab &&
                    !HardwareKeyboard.instance.isShiftPressed) {
                  if (index < widget.controllers.length - 1) {
                    widget.focusNodes[index + 1].requestFocus();
                    // Move cursor to end
                    widget.controllers[index + 1].selection =
                        TextSelection.fromPosition(
                          TextPosition(
                            offset: widget.controllers[index + 1].text.length,
                          ),
                        );
                    return KeyEventResult.handled;
                  }
                }
                // Shift+Tab: move to previous field
                else if (event.logicalKey == LogicalKeyboardKey.tab &&
                    HardwareKeyboard.instance.isShiftPressed) {
                  if (index > 0) {
                    widget.focusNodes[index - 1].requestFocus();
                    // Move cursor to end
                    widget.controllers[index - 1].selection =
                        TextSelection.fromPosition(
                          TextPosition(
                            offset: widget.controllers[index - 1].text.length,
                          ),
                        );
                    return KeyEventResult.handled;
                  }
                }
              }
              return KeyEventResult.ignored;
            },
            child: TextSelectionTheme(
              data: TextSelectionThemeData(
                cursorColor: widget.cursorColor ?? _theme.cursorColor,
                selectionColor: widget.selectionColor ?? _theme.selectionColor,
                selectionHandleColor:
                    widget.selectionHandleColor ?? _theme.selectionHandleColor,
              ),
              child: TextField(
                controller: widget.controllers[index],
                focusNode: widget.focusNodes[index],
                enabled: widget.enabled,
                textAlign: TextAlign.center,
                keyboardType: _getKeyboardType(),
                textCapitalization: widget.textCapitalization,
                maxLength: 1,
                obscureText: widget.obscureText,
                obscuringCharacter: widget.obscuringCharacter,
                style: widget.enabled
                    ? widget.textStyle
                    : widget.textStyle.copyWith(
                        color: widget.textStyle.color?.withValues(alpha: 0.5),
                      ),
                showCursor: widget.showCursor ?? _theme.showCursor,
                cursorColor: widget.cursorColor ?? _theme.cursorColor,
                cursorHeight: widget.cursorHeight ?? _theme.cursorHeight,
                cursorWidth: widget.cursorWidth ?? _theme.cursorWidth,
                decoration: _buildDecoration(index),
                inputFormatters: _getInputFormatters(),
                onChanged: (value) {
                  _onTextChanged(index, value);
                },
                onTap: () {
                  // Move cursor to end when tapped
                  widget
                      .controllers[index]
                      .selection = TextSelection.fromPosition(
                    TextPosition(offset: widget.controllers[index].text.length),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
