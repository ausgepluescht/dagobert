import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'typography.dart';

abstract final class DgRadius {
  static const card = 20.0;
  static const control = 14.0;
  static const chip = 8.0;
}

abstract final class DgShadow {
  /// Weicher, warm getönter Schatten (Espresso bei 6 %).
  static const card = [
    BoxShadow(
      color: Color(0x0F2A2118),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  static const orangeGlow = [
    BoxShadow(
      color: Color(0x592E711D),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}

abstract final class AppTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: DgColors.orange,
          brightness: Brightness.light,
        ).copyWith(
          primary: DgColors.copper,
          onPrimary: DgColors.white,
          primaryContainer: DgColors.orange,
          onPrimaryContainer: DgColors.white,
          secondary: DgColors.gold,
          onSecondary: DgColors.espresso,
          secondaryContainer: DgColors.goldDust,
          onSecondaryContainer: DgColors.espresso,
          tertiary: DgColors.calmBlue,
          onTertiary: DgColors.white,
          tertiaryContainer: DgColors.blueTint,
          onTertiaryContainer: DgColors.blueText,
          surface: DgColors.white,
          onSurface: DgColors.espresso,
          surfaceContainerLowest: DgColors.white,
          surfaceContainerLow: DgColors.warmWhite,
          surfaceContainer: DgColors.warmWhite,
          surfaceContainerHigh: DgColors.sand,
          onSurfaceVariant: DgColors.cocoa,
          outline: DgColors.sand,
          outlineVariant: DgColors.sand,
          error: DgColors.brick,
          onError: DgColors.white,
          inverseSurface: DgColors.espresso,
          onInverseSurface: DgColors.white,
          inversePrimary: DgColors.undoGold,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: DgType.family,
      textTheme: DgType.textTheme,
      scaffoldBackgroundColor: DgColors.white,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );

    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DgRadius.control),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: DgColors.white,
        foregroundColor: DgColors.espresso,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: DgType.h1,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: DgColors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: DgColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DgRadius.card),
          side: const BorderSide(color: DgColors.sand),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DgColors.copper,
          foregroundColor: DgColors.white,
          minimumSize: const Size.fromHeight(54),
          shape: controlShape,
          textStyle: const TextStyle(
            fontFamily: DgType.family,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DgColors.copper,
          backgroundColor: DgColors.warmWhite,
          side: const BorderSide(color: DgColors.sand),
          minimumSize: const Size.fromHeight(54),
          shape: controlShape,
          textStyle: const TextStyle(
            fontFamily: DgType.family,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DgColors.copper,
          textStyle: const TextStyle(
            fontFamily: DgType.family,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DgColors.orange,
        foregroundColor: DgColors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DgColors.white,
        selectedColor: DgColors.orange,
        side: const BorderSide(color: DgColors.sand),
        shape: controlShape,
        labelStyle: const TextStyle(
          fontFamily: DgType.family,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: DgColors.espresso,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: DgType.family,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: DgColors.white,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DgColors.warmWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DgRadius.control),
          borderSide: const BorderSide(color: DgColors.sand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DgRadius.control),
          borderSide: const BorderSide(color: DgColors.sand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DgRadius.control),
          borderSide: const BorderSide(color: DgColors.orange, width: 2),
        ),
        labelStyle: DgType.meta,
        hintStyle: DgType.meta,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DgColors.white,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: DgColors.sand,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DgColors.espresso,
        contentTextStyle: const TextStyle(
          fontFamily: DgType.family,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: DgColors.white,
        ),
        actionTextColor: DgColors.undoGold,
        behavior: SnackBarBehavior.floating,
        shape: controlShape,
      ),
      dividerTheme: const DividerThemeData(
        color: DgColors.sand,
        thickness: 1,
        space: 1,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(controlShape),
          side: const WidgetStatePropertyAll(BorderSide(color: DgColors.sand)),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontFamily: DgType.family,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: DgColors.copper,
        textColor: DgColors.espresso,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DgColors.orange,
        linearTrackColor: DgColors.sand,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? DgColors.white
              : DgColors.cocoa,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? DgColors.orange
              : DgColors.sand,
        ),
      ),
    );
  }
}
