import 'dart:async';
import 'package:cog_tooltip/components/tooltip_info.dart';
import 'package:cog_tooltip/components/tooltip_style.dart';
import 'package:cog_tooltip/widgets/tooltip_body.dart';
import 'package:flutter/material.dart';

class EntireShell extends StatefulWidget {
  final double x, y, h, w, padding, borderRadius;
  final TooltipInfo info;
  final TooltipStyle? style;
  final Duration? duration;
  final Function() onTapClose;
  final Function()? onTapSpecified;
  final Color veilColor;

  const EntireShell({
    Key? key,
    required this.x,
    required this.y,
    required this.h,
    required this.w,
    this.padding = 0.0,
    this.borderRadius = 0.0,
    this.duration,
    required this.onTapClose,
    this.onTapSpecified,
    required this.info,
    this.style,
    this.veilColor = const Color(0xAA000000),
  }) : super(key: key);

  @override
  EntireShellState createState() => EntireShellState();
}

class EntireShellState extends State<EntireShell> {
  bool enable = false;
  double h = 0.0;
  double w = 0.0;
  double x = 0.0;
  double y = 0.0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    start();
  }

  late Duration _duration;

  @override
  void dispose() {
    if (null != timer) {
      timer!.cancel();
    }
    super.dispose();
  }

  void start() async {
    _duration = widget.duration ?? const Duration(seconds: 1);

    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      h = widget.h + (widget.padding * 2);
      w = widget.w + (widget.padding * 2);
      x = widget.x - widget.padding;
      y = widget.y - widget.padding;
    });

    if (widget.duration != null) {
      timer = Timer.periodic(widget.duration!, (Timer t) {
        setState(() {
          h = (h == widget.h + (widget.padding * 2))
              ? widget.h - (widget.padding)
              : widget.h + (widget.padding * 2);
          w = (w == widget.w + (widget.padding * 2))
              ? widget.w - (widget.padding)
              : widget.w + (widget.padding * 2);
          x = (x == widget.x - widget.padding)
              ? widget.x + (widget.padding / 2)
              : widget.x - widget.padding;
          y = (y == widget.y - widget.padding)
              ? widget.y + (widget.padding / 2)
              : widget.y - widget.padding;
        });
      });

      await Future.delayed(widget.duration!);
    }

    setState(() {
      enable = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(widget.veilColor, BlendMode.srcOut),
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () async {
                  await _closeTooltip();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.veilColor,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
              ),
              AnimatedPositioned(
                left: x,
                top: y,
                height: h == 0.0 ? MediaQuery.of(context).size.height : h,
                width: w == 0.0 ? MediaQuery.of(context).size.width : w,
                duration: _duration,
                curve: Curves.fastOutSlowIn,
                child: GestureDetector(
                  onTap: () async {
                    if (widget.onTapSpecified != null) {
                      widget.onTapSpecified!.call();
                    }

                    await _closeTooltip();
                  },
                  onHorizontalDragStart: (DragStartDetails d) async {
                    await _closeTooltip();
                  },
                  child: Container(
                    height: h == 0 ? MediaQuery.of(context).size.height : h,
                    width: w == 0 ? MediaQuery.of(context).size.width : w,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(
                        widget.borderRadius,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        TooltipBody(
          duration: _duration,
          x: x,
          y: y,
          h: h,
          w: w,
          enable: enable,
          info: widget.info,
          style: widget.style,
          onTapClose: () async {
            await _closeTooltip();
          },
        )
      ],
    );
  }

  Future<void> _closeTooltip() async {
    if (enable) {
      setState(() {
        enable = false;
      });

      if (null != timer) {
        timer!.cancel();
      }

      setState(() {
        h = MediaQuery.of(context).size.height;
        w = MediaQuery.of(context).size.width;
        x = 0.0;
        y = 0.0;
      });

      await Future.delayed(_duration);
      widget.onTapClose();
    }
  }
}
