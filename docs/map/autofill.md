# Autofill

## What it is

How `OTPTextField` tells the platform its fields take a one-time code, and
how a code the platform fills in reaches the fields.

## Governing decisions

- Issue #11: a public `autofillHints` parameter, default
  `[AutofillHints.oneTimeCode]`, the same hints on every field; `null` turns
  autofill off. The maintainer chose it over hard-wiring the hint with no way
  to turn it off and over a parameter that is off by default (2026-11-03).
  They were shown that a real device's delivery was not measured.
- Review of #11 found that a consumer `AutofillGroup` filled by Android
  reported the code twice when `onCompleted` moved focus. The maintainer chose
  "a field without focus refuses a paste" over recording the trap only, shown
  that it also drops a fill by tag into the OTP fields while another field
  of the group has focus (2026-11-03). The rule itself is in
  [paste-handling](paste-handling.md).
- On web, `obscureText` with the default hint makes the DOM input `text`
  (Traps). The maintainer chose to document it and point to
  `autofillHints: null` over sending no hints whenever `obscureText` is true,
  shown that the latter also removes the offer on iOS and Android
  (2026-11-03). The cause is in Flutter's web engine.

## Design model

- **Every field carries the hint, not the first only.** The platform reads
  the hints of the field that has focus: iOS sets the input view's
  `textContentType` from the attached field's configuration
  (`FlutterTextInputPlugin.mm`, `configureWithDictionary:`), and Android gives
  its autofill framework the hints of the configurations attached at the time
  (`TextInputPlugin.java`, `onProvideAutofillVirtualStructure`). Focus
  moves to the next field after each typed character, so a hint on the first field only would stop the offer after
  the first digit.
- **The hint names.** Flutter's `AutofillHints.oneTimeCode` is sent to
  Android as `"smsOTPCode"` (`TextInputChannel.java`, the `oneTimeCode`
  case) and to iOS as `UITextContentTypeOneTimeCode`
  (`FlutterTextInputPlugin.mm`). Engine source read at Flutter 3.41.9.
- **A filled code goes through the paste path.** Android's
  `TextInputPlugin.autofill` sets the focused field to the whole value with
  the cursor at its end; Flutter's `EditableTextState.autofill` does the same
  for a field the platform fills by tag. iOS `insertText:` replaces the
  selection with the text. Either way one edit inserts the code into one
  field, and [paste-handling](paste-handling.md) spreads it.
- **Each field attaches alone unless the consumer adds a group.** The widget
  wraps no `AutofillGroup`, so `TextInput.attach` sends one field's
  configuration. Inside a consumer's `AutofillGroup` all fields join it, and
  Android's `TextInputPlugin.autofill` sends a group fill in two messages: the
  focused field through `updateEditingState`, then every other field by tag
  through `updateEditingStateWithTag`. The paste from the first message is
  applied in a microtask before the second arrives. Without a refocus the
  field's unfocus has closed the connection and the framework drops the
  second message (`TextInput._handleTextInputInvocation` returns while
  `_currentConnection` is null). When `onCompleted` moves focus back, the
  connection is open and each other field receives the whole code; those
  fields have no focus and refuse it. Before that rule the code was reported
  twice (probe and tests "a code autofilled into every field of an
  AutofillGroup reports once…", 2026-11-03).

## Measured on a device (2026-11-03)

Android emulator, API 36.1 Google Play image, Gboard, the example app built
from the #11 branch:

- Focusing a field starts an autofill session and a fill request to the
  Google autofill service, which returned no dataset
  (`mTotalDatasetsProvided=0`). No Google account was signed in
  (`dumpsys account`: 0), so whether a signed-in device offers the code was
  not settled.
- A code copied from the Messages notification and pasted through the field's
  Paste menu, and the same code inserted from Gboard's clipboard chip, each
  filled every field and completed the code.
- In the obscured example, Gboard showed no clipboard chip.

Web, headless Chrome 156, a probe app built against the branch: with
`obscureText`, the default hint gave `type="text" autocomplete="one-time-code"`;
`null` gave `type="password" autocomplete="off"`; `[]` gave
`type="password" autocomplete="on"`. Inside an `AutofillGroup` every field's
input had `id="one-time-code"`.

`flutter test --platform chrome` fails to load any suite in this environment
("Connection closed before test suite loaded"), so web is not covered by the
test suite.

## Traps

- Not measured: iOS at all (no macOS here), whether a signed-in Android
  device offers the SMS code, and whether any platform inserts the code more
  than once outside a group.
- `null` sends no autofill information. Flutter documents that this turns
  autofill off on Android and web only (`EditableText.autofillHints`); iOS
  then gets an empty `textContentType` (`FlutterTextInputPlugin.mm`,
  `configureWithDictionary:`), and whether iOS still offers a code was not
  measured.
- On web, `obscureText` sets the DOM input type `password`, and then the
  autofill configuration sets it to `text` for any hint that does not contain
  `password` (`text_editing.dart`, `applyConfiguration` then
  `AutofillInfo.applyToDomElement`; measured above). Before #11 the hints
  were empty and the type stayed `password`. What browsers do differently
  with the `text` input was not measured.
- On web, the focused input takes its first hint as DOM `id` and `name`
  (`AutofillInfo.applyToDomElement`), so inside a consumer `AutofillGroup`
  every field's element is named `one-time-code` (measured above). The effect
  on browsers was not measured.
- On iOS, a field with no hint content type had autofill type `None`; with
  `oneTimeCode` it is `Regular` (`FlutterTextInputPlugin.mm`,
  `AutofillTypeOf`), which the engine handles with a different input view
  lifecycle. A visible effect was not measured.
- With `obscureText` true, iOS treats the field as password-related
  whatever its hints (`IsFieldPasswordRelated` returns yes for
  `secureTextEntry`). The effect on the one-time-code offer was not measured.
- A whole value sent with the cursor at the end, as Android autofill,
  `EditableTextState.autofill` and a browser fill do, into a field that holds
  a character is refused when that character equals the code's first
  character, whatever the field's position; see
  [paste-handling](paste-handling.md), Traps.

## Code

- `lib/src/otp_textfield.dart`: `autofillHints`, the `TextField` in `build`
- `test/flutter_otp_widget_test.dart`, group `autofill`

## Cross-cutting invariants

**None.**
