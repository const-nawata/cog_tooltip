export 'package:cog_tooltip/widgets/tooltip_host.dart';
export 'package:cog_tooltip/components/tooltip_info.dart';
export 'package:cog_tooltip/components/tooltip_style.dart';
import 'package:cog_tooltip/components/tooltip_info.dart';
import 'package:cog_tooltip/components/tooltip_style.dart';
import 'package:cog_tooltip/widgets/entire_shell.dart';
import 'package:flutter/material.dart';

class CogTooltip {
  final Duration startDelay;
  final Duration? duration;
  final TooltipInfo info;
  final TooltipStyle? style;
  final BuildContext context;
  final double padding;
  final Color veilColor;
  final Function()? onTapSpecified;

  double x = 0, y = 0, h = 0, w = 0;
  OverlayEntry? overlayBlock;
  OverlayEntry? overlayEntry;

  CogTooltip(
    this.context, {
    required this.info,
    this.style,
    this.startDelay = const Duration(milliseconds: 1),
    this.duration,
    this.padding = 10.0,
    this.veilColor = const Color(0xAA000000),
    this.onTapSpecified,
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
      return EntireShell(
        x: x,
        y: y,
        h: h,
        w: w,
        duration: duration,
        padding: padding,
        veilColor: veilColor,
        info: info,
        style: style,
        onTapSpecified: onTapSpecified,
        onTapClose: () {
          _removeOverlay();
        },
      );
    });
  }

  void show() {
    try {
      Future.delayed(startDelay, () {
        RenderBox box = GlobalObjectKey(info.initial!)
            .currentContext!
            .findRenderObject() as RenderBox;

        Offset position = box.localToGlobal(Offset.zero);
        y = position.dy;
        x = position.dx;
        h = box.size.height;
        w = box.size.width;

        if (overlayEntry == null) {
          overlayBlock = buildOverlayBlock();
          Overlay.of(context)?.insert(overlayBlock!);
          overlayEntry = buildOverlay();
          Overlay.of(context)?.insert(overlayEntry!);
        }
      });
    } catch (e) {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    overlayBlock?.remove();
    overlayBlock = null;
    overlayEntry?.remove();
    overlayEntry = null;
  }
}
