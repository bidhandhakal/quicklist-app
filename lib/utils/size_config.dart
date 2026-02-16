import 'package:flutter/material.dart';

/// Responsive size configuration utility
/// Helps maintain consistent UI across different screen sizes
class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double textScaleFactor;

  /// Initialize SizeConfig with context
  /// Call this in the build method of your root widget
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    textScaleFactor = _mediaQueryData.textScaler.scale(1.0);

    // Calculate blocks (1% of screen)
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    // Calculate safe area blocks (excluding notch, status bar, etc.)
    final safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    final safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  /// Get responsive width based on design size (e.g., from Figma)
  /// designWidth: The width value from your design (e.g., 375 for iPhone SE)
  static double getProportionateScreenWidth(
    double inputWidth, {
    double designWidth = 375,
  }) {
    final scale = (screenWidth / designWidth).clamp(0.85, 1.2);
    return inputWidth * scale;
  }

  /// Get responsive height based on design size
  /// designHeight: The height value from your design (e.g., 812 for iPhone X)
  static double getProportionateScreenHeight(
    double inputHeight, {
    double designHeight = 812,
  }) {
    final scale = (screenHeight / designHeight).clamp(0.85, 1.2);
    return inputHeight * scale;
  }

  /// Get responsive font size
  /// Ensures text remains readable across devices
  static double getResponsiveFontSize(
    double fontSize, {
    double designWidth = 375,
  }) {
    double scaleFactor = screenWidth / designWidth;
    // Tighter clamp to prevent oversized text on larger screens
    scaleFactor = scaleFactor.clamp(0.85, 1.12);
    return fontSize * scaleFactor;
  }

  /// Check if device is a tablet
  static bool isTablet() {
    return screenWidth >= 600;
  }

  /// Check if device is a small phone
  static bool isSmallPhone() {
    return screenWidth < 360;
  }

  /// Check if device is a large phone
  static bool isLargePhone() {
    return screenWidth > 400 && screenWidth < 600;
  }

  /// Get horizontal padding for screen edges
  static double get defaultHorizontalPadding => getProportionateScreenWidth(16);

  /// Get vertical padding for screen edges
  static double get defaultVerticalPadding => getProportionateScreenHeight(16);

  /// Get default border radius
  static double get defaultBorderRadius => getProportionateScreenWidth(12);

  /// Get card elevation
  static double get defaultElevation => isTablet() ? 4 : 2;
}

/// Extension on BuildContext for easy access to responsive sizes
extension ResponsiveContext on BuildContext {
  /// Get responsive width
  double wp(double percentage) => SizeConfig.screenWidth * (percentage / 100);

  /// Get responsive height
  double hp(double percentage) => SizeConfig.screenHeight * (percentage / 100);

  /// Get responsive width based on design width
  double rw(double inputWidth, {double designWidth = 375}) =>
      SizeConfig.getProportionateScreenWidth(
        inputWidth,
        designWidth: designWidth,
      );

  /// Get responsive height based on design height
  double rh(double inputHeight, {double designHeight = 812}) =>
      SizeConfig.getProportionateScreenHeight(
        inputHeight,
        designHeight: designHeight,
      );

  /// Get responsive font size
  double rf(double fontSize, {double designWidth = 375}) =>
      SizeConfig.getResponsiveFontSize(fontSize, designWidth: designWidth);

  /// Get screen width
  double get screenWidth => SizeConfig.screenWidth;

  /// Get screen height
  double get screenHeight => SizeConfig.screenHeight;

  /// Check if tablet
  bool get isTablet => SizeConfig.isTablet();

  /// Check if small phone
  bool get isSmallPhone => SizeConfig.isSmallPhone();

  /// Check if large phone
  bool get isLargePhone => SizeConfig.isLargePhone();
}
