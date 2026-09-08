import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/theme/app_colors.dart';
import 'package:subh_warrior/core/theme/app_snack_bars.dart';
import 'package:subh_warrior/core/theme/app_theme.dart';

void main() {
  // Regression: the snackbar theme used to hand `SnackBar` a bare
  // `textTheme.bodyMedium`, whose onSurface ink is meant for the canvas — dark
  // text on the dark `inverseSurface` fill. Every flavour's label must read
  // against the fill it actually sits on.
  group('snackbar ink pairs with its fill', () {
    for (final (name, theme) in [
      ('light', AppTheme.light()),
      ('dark', AppTheme.dark()),
    ]) {
      test('$name theme labels neutral snackbars with onInverseSurface', () {
        expect(
          theme.snackBarTheme.contentTextStyle?.color,
          theme.colorScheme.onInverseSurface,
        );
      });
    }

    Future<SnackBar> showAndCapture(
      WidgetTester tester,
      ThemeData theme,
      AppSnackKind kind,
    ) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(builder: (context) {
            capturedContext = context;
            return const SizedBox();
          }),
        ),
      ));
      return appSnackBar(capturedContext, 'message', kind: kind);
    }

    Color? labelColor(SnackBar snackBar) =>
        (snackBar.content as Text).style?.color;

    testWidgets('error snackbar labels with onError', (tester) async {
      final theme = AppTheme.light();
      final snackBar = await showAndCapture(tester, theme, AppSnackKind.error);

      expect(snackBar.backgroundColor, theme.colorScheme.error);
      expect(labelColor(snackBar), theme.colorScheme.onError);
    });

    testWidgets('warning snackbar labels with onWarning', (tester) async {
      final theme = AppTheme.light();
      final colors = theme.extension<AppColorsX>()!;
      final snackBar =
          await showAndCapture(tester, theme, AppSnackKind.warning);

      expect(snackBar.backgroundColor, colors.warning);
      expect(labelColor(snackBar), colors.onWarning);
    });

    testWidgets('success snackbar labels with onSuccess', (tester) async {
      final theme = AppTheme.light();
      final colors = theme.extension<AppColorsX>()!;
      final snackBar =
          await showAndCapture(tester, theme, AppSnackKind.success);

      expect(snackBar.backgroundColor, colors.success);
      expect(labelColor(snackBar), colors.onSuccess);
    });

    testWidgets('neutral snackbar defers to the theme', (tester) async {
      final snackBar = await showAndCapture(
          tester, AppTheme.light(), AppSnackKind.neutral);

      expect(snackBar.backgroundColor, isNull);
      expect(labelColor(snackBar), isNull);
    });

    testWidgets('a semantic action is re-inked to match the fill',
        (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Builder(builder: (context) {
            capturedContext = context;
            return const SizedBox();
          }),
        ),
      ));

      final snackBar = appSnackBar(
        capturedContext,
        'message',
        kind: AppSnackKind.error,
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      );

      expect(snackBar.action?.label, 'Undo');
      expect(
        snackBar.action?.textColor,
        Theme.of(capturedContext).colorScheme.onError,
      );
    });
  });
}