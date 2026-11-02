import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_widget/flutter_otp_widget.dart';
import 'package:flutter_test/flutter_test.dart';

/// Drives one [OTPTextField] the way a user does: tapping, typing and pasting
/// from a mocked platform clipboard.
class _Harness {
  _Harness(this.tester, {required this.length});

  final WidgetTester tester;
  final int length;
  late final List<TextEditingController> controllers = List.generate(
    length,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> focusNodes = List.generate(
    length,
    (_) => FocusNode(),
  );
  final List<String> changes = [];
  final List<String> completions = [];

  List<String> get texts => controllers.map((c) => c.text).toList();

  Future<void> pump({
    OTPInputType inputType = OTPInputType.number,
    bool enabled = true,
  }) async {
    addTearDown(() {
      for (final c in controllers) {
        c.dispose();
      }
      for (final f in focusNodes) {
        f.dispose();
      }
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OTPTextField(
            controllers: controllers,
            focusNodes: focusNodes,
            textStyle: const TextStyle(fontSize: 20),
            inputType: inputType,
            enabled: enabled,
            onChange: changes.add,
            onCompleted: completions.add,
          ),
        ),
      ),
    );
  }

  Finder field(int index) => find.byType(EditableText).at(index);

  /// Types [text] into field [index] one character at a time, as a keyboard
  /// inserts it at the cursor.
  Future<void> type(int index, String text) async {
    await tester.tap(field(index));
    await tester.pump();
    for (final char in text.split('')) {
      final state = tester.state<EditableTextState>(field(index));
      final value = state.textEditingValue;
      final selection = value.selection.isValid
          ? value.selection
          : TextSelection.collapsed(offset: value.text.length);
      final next = value.replaced(selection, char);
      tester.testTextInput.updateEditingValue(next);
      await tester.pump();
    }
  }

  /// Pastes [clip] into field [index] through the clipboard, as Ctrl+V or the
  /// paste menu does.
  ///
  /// A disabled field cannot be tapped, so with [tap] false the cursor is
  /// placed directly instead.
  Future<void> paste(int index, String clip, {bool tap = true}) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.getData') {
          return <String, dynamic>{'text': clip};
        }
        if (call.method == 'Clipboard.hasStrings') {
          return <String, dynamic>{'value': true};
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    if (tap) {
      await tester.tap(field(index));
    } else {
      controllers[index].selection = TextSelection.collapsed(
        offset: controllers[index].text.length,
      );
    }
    await tester.pump();
    await tester
        .state<EditableTextState>(field(index))
        .pasteText(SelectionChangedCause.keyboard);
    await tester.pump();
  }
}

void main() {
  group('paste', () {
    testWidgets('a full code pasted into the first field fills every field', (
      tester,
    ) async {
      final h = _Harness(tester, length: 6);
      await h.pump();

      await h.paste(0, '123456');

      expect(h.texts, ['1', '2', '3', '4', '5', '6']);
      expect(h.changes, ['123456']);
      expect(h.completions, ['123456']);
    });

    for (final index in [2, 5]) {
      testWidgets('a full code pasted into field $index fills from the first', (
        tester,
      ) async {
        final h = _Harness(tester, length: 6);
        await h.pump();

        await h.paste(index, '123456');

        expect(h.texts, ['1', '2', '3', '4', '5', '6']);
        expect(h.changes, ['123456']);
        expect(h.completions, ['123456']);
      });
    }

    testWidgets('a paste over typed fields replaces all of them', (
      tester,
    ) async {
      final h = _Harness(tester, length: 6);
      await h.pump();
      await h.type(0, '9');
      await h.type(1, '8');
      h.changes.clear();

      await h.paste(1, '123456');

      expect(h.texts, ['1', '2', '3', '4', '5', '6']);
      expect(h.changes, ['123456']);
      expect(h.completions, ['123456']);
    });

    testWidgets('a paste the platform sends as a whole new value fills every '
        'field', (tester) async {
      final h = _Harness(tester, length: 6);
      await h.pump();
      await h.type(0, '9');
      await tester.tap(h.field(0));
      await tester.pump();
      h.changes.clear();

      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: '9123456',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );
      await tester.pump();

      expect(h.texts, ['1', '2', '3', '4', '5', '6']);
      expect(h.changes, ['123456']);
      expect(h.completions, ['123456']);
    });

    testWidgets('the field that received the paste loses focus', (
      tester,
    ) async {
      final h = _Harness(tester, length: 6);
      await h.pump();

      await h.paste(2, '123456');

      expect(h.focusNodes.where((f) => f.hasFocus), isEmpty);
    });

    for (final clip in ['123 456', '123-456', 'Your code is [123456].']) {
      testWidgets('"$clip" pastes as the code', (tester) async {
        final h = _Harness(tester, length: 6);
        await h.pump();

        await h.paste(0, clip);

        expect(h.texts, ['1', '2', '3', '4', '5', '6']);
        expect(h.changes, ['123456']);
        expect(h.completions, ['123456']);
      });
    }

    for (final clip in ['1234', '1234567', 'Code 123456, valid 3 min']) {
      testWidgets('"$clip" changes nothing', (tester) async {
        final h = _Harness(tester, length: 6);
        await h.pump();
        await h.type(0, '9');
        await h.type(1, '8');
        h.changes.clear();

        await h.paste(2, clip);

        expect(h.texts, ['9', '8', '', '', '', '']);
        expect(h.changes, isEmpty);
        expect(h.completions, isEmpty);
      });
    }

    testWidgets('a short paste over a filled field keeps its character', (
      tester,
    ) async {
      final h = _Harness(tester, length: 6);
      await h.pump();
      await h.type(0, '9');
      h.changes.clear();

      await h.paste(0, '12');

      expect(h.texts, ['9', '', '', '', '', '']);
      expect(h.changes, isEmpty);
      expect(h.completions, isEmpty);
    });

    testWidgets('an onChange that throws is reported and does not stop the '
        'paste', (tester) async {
      final h = _Harness(tester, length: 4);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OTPTextField(
              controllers: h.controllers,
              focusNodes: h.focusNodes,
              textStyle: const TextStyle(fontSize: 20),
              onChange: (_) => throw StateError('consumer'),
              onCompleted: h.completions.add,
            ),
          ),
        ),
      );

      await h.paste(1, '1234');

      expect(tester.takeException(), isA<StateError>());
      expect(h.texts, ['1', '2', '3', '4']);
      expect(h.completions, ['1234']);
      expect(h.focusNodes.where((f) => f.hasFocus), isEmpty);
    });

    testWidgets('inputType.text keeps letters only', (tester) async {
      final h = _Harness(tester, length: 4);
      await h.pump(inputType: OTPInputType.text);

      await h.paste(0, 'a1-B2 c3 D');

      expect(h.texts, ['a', 'B', 'c', 'D']);
      expect(h.completions, ['aBcD']);
    });

    testWidgets('inputType.any keeps letters and digits', (tester) async {
      final h = _Harness(tester, length: 4);
      await h.pump(inputType: OTPInputType.any);

      await h.paste(0, 'a1-B2!');

      expect(h.texts, ['a', '1', 'B', '2']);
      expect(h.completions, ['a1B2']);
    });

    testWidgets('a disabled field accepts no paste', (tester) async {
      final h = _Harness(tester, length: 6);
      await h.pump(enabled: false);

      await h.paste(0, '123456', tap: false);

      expect(h.texts, ['', '', '', '', '', '']);
      expect(h.changes, isEmpty);
      expect(h.completions, isEmpty);
    });
  });

  group('typing', () {
    testWidgets('one character at a time moves forward and completes once', (
      tester,
    ) async {
      final h = _Harness(tester, length: 4);
      await h.pump();

      for (var i = 0; i < 4; i++) {
        await h.type(i, '${i + 1}');
        if (i < 3) {
          expect(h.focusNodes[i + 1].hasFocus, isTrue);
        }
      }

      expect(h.texts, ['1', '2', '3', '4']);
      expect(h.changes, ['1', '12', '123', '1234']);
      expect(h.completions, ['1234']);
      expect(h.focusNodes.where((f) => f.hasFocus), isEmpty);
    });

    testWidgets('a second character typed into a filled field is dropped', (
      tester,
    ) async {
      final h = _Harness(tester, length: 4);
      await h.pump();
      await h.type(0, '1');

      await h.type(0, '2');

      expect(h.texts, ['1', '', '', '']);
      expect(h.completions, isEmpty);
    });
  });
}
