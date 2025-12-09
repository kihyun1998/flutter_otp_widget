# Changelog

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
