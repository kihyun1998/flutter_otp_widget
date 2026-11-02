# Completion focus

## What it is

What happens to focus when a code is completed: by typing into the last
field, or by a paste.

## Governing decisions

- Issue #10: the completing field's unfocus is requested **after
  `onChange` and before `onCompleted`**, on both paths. The maintainer chose
  "unfocus before the callbacks" over skipping the unfocus when the consumer
  moved focus and over documenting a next-frame refocus (2026-11-02), then
  placed it after `onChange` once review showed that an unfocus before
  `onChange` changed 1.0.3's behaviour for consumers that clear the fields in
  `onChange` (2026-11-03).
- Typing unfocuses only when the **last** field completes the code; a paste
  always unfocuses the receiving field. Kept as is when #10 was decided
  (maintainer, 2026-11-02).

## Design model

- **Why the unfocus comes first.** `FocusNode.requestFocus` does not move
  focus at once: it records the node as the scope's focused child and marks
  it as the next focus, applied later in a microtask. `FocusNode.unfocus` on
  a node that still has focus marks its scope as the next focus, and the
  last mark wins (Flutter 3.41.9, `widgets/focus_manager.dart`, `unfocus` and
  `_doRequestFocus`). An unfocus after `onCompleted` therefore overrode any
  focus it requested; before it, the callback's request is the last mark. A
  focus requested in `onChange` at the moment of completion is still
  overridden, as in 1.0.3.
- **Skipping the unfocus when the consumer moved focus does not work.**
  `_doRequestFocus` returns early for a node that already has primary focus,
  so a request for the field that just received a paste leaves no trace to
  detect, and there is no public getter for the pending focus.
- **Typing decides completion from the fields after `onChange`.** A consumer
  that clears the fields in `onChange` gets no unfocus and no `onCompleted`,
  and the last field keeps focus, as in 1.0.3.
- Inside the callbacks the completing field still reports `hasFocus` and is
  still `primaryFocus`; its scope's `focusedChild` reads null (fresh-agent
  measurement, 2026-11-02).

## Traps

- With typing, a code completed in a field other than the last, as when the
  fields are filled out of order, leaves that field focused and the keyboard
  open; the paste path never does.
- A next-frame refocus (`addPostFrameCallback`) also works, but closes and
  reopens the keyboard (`TextInput.hide` then `show`, fresh-agent
  measurement, 2026-11-02).

## Code

- `lib/src/otp_textfield.dart`: `_onTextChanged`, `_applyPendingPaste`
- `test/flutter_otp_widget_test.dart`: group `completion`

## Cross-cutting invariants

**None.**
