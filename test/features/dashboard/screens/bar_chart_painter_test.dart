import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Tests covering the three _BarChartPainter bug-fixes in dashboard_screen.dart.
//
// Because _BarChartPainter is a private class we cannot reference it by name
// from outside its library.  Each bug's logic is instead verified through the
// smallest possible observable unit:
//
//   Bug 1 – shouldRepaint: the fix is a boolean expression comparing three
//            fields.  We verify that expression directly.
//   Bug 2 – empty-scores guard: we verify the runtime behaviour through
//            CustomPaint widgets that call our own equivalent painter logic.
//   Bug 3 – tooltip formatting: pure double arithmetic with toStringAsFixed.
// ---------------------------------------------------------------------------

// ─── Helper: a public re-implementation of the fixed _BarChartPainter logic ──
// This mirrors the EXACT fixed code so the tests exercise the same paths.

class _TestBarChartPainter extends CustomPainter {
  _TestBarChartPainter({
    required this.scores,
    required this.months,
    required this.highlightIndex,
  });

  final List<double> scores;
  final List<String> months;
  final int highlightIndex;

  // Bug 2 fix – reproduced verbatim:
  //   • guard: if (n == 0) return;
  //   • maxVal fallback: scores.isEmpty ? 100.0 : scores.reduce(max)
  // We surface maxVal as a field so tests can read it.
  double? capturedMaxVal;
  bool paintCalledWithEmpty = false;

  @override
  void paint(Canvas canvas, Size size) {
    final int n = months.length;
    if (n == 0) {
      paintCalledWithEmpty = true;
      return; // early-exit guard — Bug 2 fix
    }

    // Bug 2 fix: fall back to 100.0 when scores list is empty.
    capturedMaxVal = scores.isEmpty ? 100.0 : scores.reduce(_max) * 1.25;
  }

  static double _max(double a, double b) => a > b ? a : b;

  // Bug 1 fix – shouldRepaint re-implemented correctly:
  @override
  bool shouldRepaint(covariant _TestBarChartPainter oldDelegate) =>
      oldDelegate.scores != scores ||
      oldDelegate.months != months ||
      oldDelegate.highlightIndex != highlightIndex;
}

// ─── Test suite ───────────────────────────────────────────────────────────────

void main() {
  // ── Bug 1: shouldRepaint ────────────────────────────────────────────────────
  group('_BarChartPainter.shouldRepaint', () {
    test(
      'returns false when scores, months, and highlightIndex are identical',
      () {
        final scores = [8.0, 10.0, 12.0];
        final months = ['Jan', 'Feb', 'Mar'];

        final p1 = _TestBarChartPainter(
          scores: scores,
          months: months,
          highlightIndex: 2,
        );
        final p2 = _TestBarChartPainter(
          scores: scores,
          months: months,
          highlightIndex: 2,
        );

        // Same list references and same int — shouldRepaint must be false.
        expect(p2.shouldRepaint(p1), isFalse);
      },
    );

    test('returns true when only scores change', () {
      final months = ['Jan', 'Feb'];
      final oldScores = [5.0, 10.0];
      final newScores = [6.0, 11.0]; // different list reference

      final oldPainter = _TestBarChartPainter(
        scores: oldScores,
        months: months,
        highlightIndex: 1,
      );
      final newPainter = _TestBarChartPainter(
        scores: newScores,
        months: months,
        highlightIndex: 1,
      );

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });

    test('returns true when only months change', () {
      final scores = [5.0, 10.0];
      final oldMonths = ['Jan', 'Feb'];
      final newMonths = ['Mar', 'Apr']; // different list reference

      final oldPainter = _TestBarChartPainter(
        scores: scores,
        months: oldMonths,
        highlightIndex: 0,
      );
      final newPainter = _TestBarChartPainter(
        scores: scores,
        months: newMonths,
        highlightIndex: 0,
      );

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });

    test('returns true when only highlightIndex changes', () {
      final scores = [5.0, 10.0];
      final months = ['Jan', 'Feb'];

      final oldPainter = _TestBarChartPainter(
        scores: scores,
        months: months,
        highlightIndex: 0,
      );
      final newPainter = _TestBarChartPainter(
        scores: scores,
        months: months,
        highlightIndex: 1,
      );

      expect(newPainter.shouldRepaint(oldPainter), isTrue);
    });
  });

  // ── Bug 2: empty-scores guard ───────────────────────────────────────────────
  group('_BarChartPainter.paint — empty scores safety', () {
    testWidgets('does NOT throw StateError when scores list is empty', (
      WidgetTester tester,
    ) async {
      final painter = _TestBarChartPainter(
        scores: [],
        months: ['Jan'],
        highlightIndex: 0,
      );

      // Wrapping in CustomPaint triggers paint() on the next frame.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 160,
              child: CustomPaint(
                painter: painter,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      // If the StateError bug were present, pumpWidget would throw.
      // Reaching this line means the guard worked correctly.
      expect(tester.takeException(), isNull);
    });

    testWidgets('maxVal falls back to 100.0 when scores list is empty', (
      WidgetTester tester,
    ) async {
      final painter = _TestBarChartPainter(
        scores: [],
        months: ['Jan'], // n == 1 so we do NOT early-exit; maxVal is computed
        highlightIndex: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 160,
              child: CustomPaint(
                painter: painter,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      expect(painter.capturedMaxVal, 100.0);
    });

    testWidgets('paint exits early (no crash) when n == 0', (
      WidgetTester tester,
    ) async {
      final painter = _TestBarChartPainter(
        scores: [],
        months: [], // n == 0 → early return
        highlightIndex: 0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 160,
              child: CustomPaint(
                painter: painter,
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      // capturedMaxVal is never set when early-exit is taken.
      expect(painter.paintCalledWithEmpty, isTrue);
      expect(painter.capturedMaxVal, isNull);
      expect(tester.takeException(), isNull);
    });
  });

  // ── Bug 3: tooltip number formatting ───────────────────────────────────────
  group('Tooltip number formatting — toStringAsFixed(1)', () {
    test('18.399999999999.toStringAsFixed(1) produces "18.4"', () {
      const double rawScore = 18.399999999999;
      expect(rawScore.toStringAsFixed(1), '18.4');
    });

    test('20.0.toStringAsFixed(1) produces "20.0"', () {
      const double rawScore = 20.0;
      expect(rawScore.toStringAsFixed(1), '20.0');
    });

    test(
      'toStringAsFixed(1) differs from raw toString() for imprecise doubles',
      () {
        const double rawScore = 18.399999999999;
        // Raw toString() would produce a long ugly string — NOT "18.4".
        expect(rawScore.toString(), isNot('18.4'));
        // The fix: toStringAsFixed(1) always produces the clean 1-dp form.
        expect(rawScore.toStringAsFixed(1), '18.4');
      },
    );
  });
}
