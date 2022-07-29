import 'dart:ui';

class TooltipStyle {
  TooltipStyle({
    this.maxWidth,
    this.tooltipShift,
    this.cogShift,
    this.titleColor,
    this.subTitleColor,
    this.backgroundColor,
    this.borderRadius,
  });

  double? maxWidth;

  /// Positive value => sift to right
  /// Negative value => sift to left
  double? tooltipShift;

  /// Positive value => sift to right
  /// Negative value => sift to left
  double? cogShift;

  Color? titleColor;
  Color? subTitleColor;
  Color? backgroundColor;
  double? borderRadius;
}
