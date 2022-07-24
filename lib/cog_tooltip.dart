library cog_tooltip;

export './src/widgets/tooltip_owner.dart';
export './src/models/coach_button_model.dart';
export './src/models/coach_model.dart';
import 'package:cog_tooltip/cog_tooltip.dart';
import 'package:cog_tooltip/src/widgets/widget_card.dart';
import 'package:cog_tooltip/src/widgets/widget_main.dart';
import 'package:flutter/material.dart';

enum CoachMakerControl { none, next, close }

class CogTooltip {
  final Duration firstDelay;
  final Duration? duration;
  final List<CoachModel> initialList;
  final BuildContext context;
  final Function()? skip;
  final CoachMakerControl nextStep;
  final CoachButtonOptions? buttonOptions;
  final double padding;
  final Color veilColor;
  final Function()? onTapNext;
  final Function()? onTapSpecified;
  final PointerPosition position;

  /// Positive value => sift to right
  /// Negative value => sift to left
  final double lrShift;

  double x = 0, y = 0, h = 0, w = 0;
  OverlayEntry? overlayBlock;
  OverlayEntry? overlayEntry;
  int currentIndex = 0;

  CogTooltip(
    this.context, {
    required this.initialList,
    this.firstDelay = const Duration(milliseconds: 1),
    this.duration,
    this.skip,
    this.nextStep = CoachMakerControl.next,
    this.buttonOptions,
    this.padding = 10.0,
    this.veilColor = const Color(0xAA000000),
    this.onTapNext,
    this.onTapSpecified,
    this.position = PointerPosition.center,
    this.lrShift = 0.0,
  });

  OverlayEntry buildOverlayBlock() {
    return OverlayEntry(builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.transparent,
      );
    });
  }

  OverlayEntry buildOverlay() {
    return OverlayEntry(builder: (context) {
      return WidgetMain(
        x: x,
        y: y,
        h: h,
        w: w,
        duration: duration,
        padding: padding,
        veilColor: veilColor,
        buttonOptions: buttonOptions ?? CoachButtonOptions(),
        position: position,
        lrShift: lrShift,
        model: initialList[currentIndex],
        onTapSpecified: onTapSpecified,
        onSkip: skip == null
            ? null
            : () {
                removeOverlay();
                overlayBlock?.remove();
                overlayBlock = null;
                skip!();
              },
        onTapNext: () {
          switch (nextStep) {
            case CoachMakerControl.next:
              nextOverlay();
              break;
            case CoachMakerControl.close:
              removeOverlay();
              break;
            case CoachMakerControl.none:
              break;
            default:
          }

          if (onTapNext != null) {
            onTapNext!.call();
          }
        },
      );
    });
  }

  void show() {
    try {
      Future.delayed(
          currentIndex == 0 ? firstDelay : const Duration(milliseconds: 1), () {
        RenderBox box = GlobalObjectKey(initialList[currentIndex].initial!)
            .currentContext!
            .findRenderObject() as RenderBox;

        Offset position = box.localToGlobal(Offset.zero);
        y = position.dy;
        x = position.dx;
        h = box.size.height;
        w = box.size.width;

        if (overlayEntry == null) {
          if (currentIndex == 0) {
            overlayBlock = buildOverlayBlock();
            Overlay.of(context)?.insert(overlayBlock!);
          }
          overlayEntry = buildOverlay();
          Overlay.of(context)?.insert(overlayEntry!);
        }
      });
    } catch (e) {
      overlayBlock?.remove();
      overlayBlock = null;

      overlayEntry?.remove();
      overlayEntry = null;
    }
  }

  void removeOverlay() {
    if (currentIndex == initialList.length) {
      overlayBlock?.remove();
      overlayBlock = null;
    }
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void nextOverlay() {
    currentIndex++;
    removeOverlay();
    if (currentIndex < initialList.length) show();
  }
}
