# Changelog

## [Unreleased]

### Features
- Every field now sends `AutofillHints.oneTimeCode` to the platform by default, so the keyboard can offer a one-time code it received, such as one from an SMS. A new `autofillHints` parameter replaces the hints on every field; `null` sends no autofill information, which on Android and web also turns autofill off. An autofilled code is handled as a paste.

### Behaviour changes
- Fields that set no `autofillHints` now send `oneTimeCode` instead of no hints, so the platform may offer codes where it offered nothing before. Pass `autofillHints: null` to keep them out of autofill.
- On web, a field with `obscureText` and the default hint is now a DOM `text` input instead of `password`, a result of Flutter's web autofill handling. Pass `autofillHints: null` to keep it a password input.
- A field without focus now refuses a paste. This keeps a code that an `AutofillGroup` fills into every field from being reported twice.

## [1.1.0]

### Features
- Pasting a whole code into any field fills every field from the first, then calls `onChange` and `onCompleted` once each with the full code. Only the characters `inputType` allows are kept, so a code copied with spaces, hyphens or surrounding text pastes as the code.

### Fixes
- A focus requested inside `onCompleted`, such as moving back to the first field after clearing a wrong code, now holds. When the code is completed in the last field or by a paste, that field's unfocus is now requested after `onChange` and before `onCompleted`, instead of after both.

### Behaviour changes
- A paste that leaves a number of allowed characters other than the field count now changes nothing. Before, a paste into an empty field kept its first allowed character.

## [1.0.3]

### Fixes
- Fixed text vertical alignment in OTP fields by changing default `contentPadding` to `EdgeInsets.zero`
- Added `contentPadding` property to `OTPTheme` for customizable text field padding

## [1.0.2]

### Features
- Added `selectionColor` and `selectionHandleColor` properties for customizing text selection appearance

### Fixes
- Fixed Tab and Shift+Tab keyboard navigation to properly move between OTP fields

## [1.0.1]

### Improvements
- Enhanced example app with manual clear functionality and better focus management

## [1.0.0]

### Initial Release

#### Features
- **Multiple Field Styles**: Box, underline, and circle styles
- **Flexible Input Types**: Support for numbers, text, and alphanumeric input
- **Theming System**: Light, dark, and fully customizable themes
- **State Management**: Error states, disabled states, and focus management
- **Secure Input**: Password/PIN mode with obscured text
- **Keyboard Navigation**: Arrow keys and backspace navigation between fields
- **Auto Focus**: Optional automatic focus on first field
- **Customizable Layout**: Adjustable field sizes, spacing, and center gaps
- **Text Formatting**: Text capitalization options
- **Cursor Customization**: Control cursor appearance (color, size, visibility)
- **Callbacks**: `onChange` and `onCompleted` event handlers

#### Components
- `OTPTextField`: Main widget for OTP input
- `OTPTheme`: Theme configuration class
- `OTPFieldStyle`: Enum for field visual styles
- `OTPInputType`: Enum for input type control
