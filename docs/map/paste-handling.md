# Paste handling

## What it is

How `OTPTextField` turns one edit that inserts several characters into a
filled set of fields: the per-field paste formatter, the deferred spread over
all controllers, and the single `onChange`/`onCompleted` report.

## Governing decisions

Issue #4: exact length or nothing, replace all fields from the first, one
`onChange` then one `onCompleted`, the receiving field loses focus. When it
loses focus is in [completion-focus](completion-focus.md).

## Design model

- **A paste is detected from the inserted text, not the field's whole text.**
  `EditableTextState.pasteText` inserts at the selection
  (`replaced(selection, text)`), so a paste into a field holding `1` arrives
  as `1123456`. `_insertedText` takes what the edit put between the text
  before and after the old selection; when the new value does not keep that
  text, as with a platform replacing the whole value, it takes the whole new
  text.
- **The paste formatter runs before the length limit.** `TextField` appends
  its own `LengthLimitingTextInputFormatter(maxLength)` after
  `inputFormatters` (Flutter 3.41.9, `material/text_field.dart`), and the
  widget's own filter and limit follow the paste formatter, so only the
  paste formatter sees the untruncated edit.
- **The spread and the callbacks run in a microtask, not in the formatter.**
  `EditableText._formatAndSetValue` writes the formatted value into the
  controller only after every formatter has returned, and calls `onChanged`
  only when the text differs from the old value
  (`widgets/editable_text.dart`). A callback fired from the formatter would
  see the receiving controller still holding its old text, and a consumer
  that clears the fields in `onCompleted` would have the receiving field
  overwritten when the formatter's value lands. The microtask runs after that
  write, whether or not `onChanged` fired.
- **`_onTextChanged` ignores the receiving field's own `onChanged`** while a
  paste is pending, so the paste is reported once. Controllers written from
  code do not fire `onChanged`.

## Traps

- `tester.enterText` replaces the whole value with the cursor at the end
  (`flutter_test` `TestTextInput.enterText`); it is not a paste into a filled
  field. The tests paste through a mocked `Clipboard.getData` and
  `EditableTextState.pasteText`, and through `updateEditingValue` with the
  code inserted at the cursor, which is how a paste from iOS's system context
  menu arrives: on iOS `TextField` builds `SystemContextMenu`
  (`material/text_field.dart`), whose Paste the platform performs.
- `pasteText` does nothing while the selection is invalid, which is the
  state of a fresh controller. The tests tap the field first, which runs the
  widget's `onTap` and puts the cursor at the end.
- Any edit that inserts more than one character counts as a paste, a
  keyboard commit of a whole word included. With `inputType.text` and four
  fields, typing `h` moves focus to the second field; an IME update that then
  sends `hope` as that empty field's value fills all four fields and calls
  `onCompleted('hope')` (probe, 2026-11-02). The widget does not turn off
  `autocorrect` or `enableSuggestions`. Whether a real keyboard sends such an
  update was not measured.
- A platform update that replaces the whole value while the cursor sits after
  the old character is read as an insertion when the new text starts with that
  character: `1` with the cursor at 1, updated to `123456`, reads as `23456`
  and is refused (code path read 2026-11-02). Two SDK paths send a whole value
  with the cursor at the end: the accessibility `setText` action
  (`RenderEditable._handleSetText`) and `EditableTextState.autofill`. The
  widget passes no `autofillHints`; `TextField`'s default is an empty list,
  which still sends an enabled `AutofillConfiguration` with no hints
  (`widgets/editable_text.dart`, `textInputConfiguration`). Whether a platform
  autofills such a field was not measured.
- Consumer callbacks run from the microtask, outside `EditableText`'s
  try/catch, so `_reportPaste` catches and reports to `FlutterError` itself;
  a throwing `onChange` does not stop `onCompleted`.

## Code

- `lib/src/otp_textfield.dart`: `_formatPaste`, `_insertedText`,
  `_applyPendingPaste`, `_reportPaste`, `_getInputFormatters`,
  `_onTextChanged`
- `test/flutter_otp_widget_test.dart`

## Cross-cutting invariants

**None.**
