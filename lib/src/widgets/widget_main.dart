import 'dart:async';

import 'package:cog_tooltip/cog_tooltip.dart';
import 'package:cog_tooltip/src/widgets/widget_card.dart';
import 'package:flutter/material.dart';

class WidgetMain extends StatefulWidget {
  final double x, y, h, w, padding, borderRadius;
  final CoachModel model;
  final CoachButtonOptions? buttonOptions;
  final Duration? duration;

  final Function()? onSkip;
  final Function()? onTapNext;
  final Color veilColor;

  const WidgetMain({
    Key? key,
    required this.x,
    required this.y,
    required this.h,
    required this.w,
    this.padding = 0.0,
    this.borderRadius = 0.0,
    this.duration,
    this.onSkip,
    this.onTapNext,
    this.buttonOptions,
    required this.model,
    this.veilColor = const Color(0xAA000000),
  }) : super(key: key);

  @override
  WidgetMainState createState() => WidgetMainState();
}

class WidgetMainState extends State<WidgetMain> {
  ///flag for show card
  ///
  bool enable = false;

  ///height
  ///
  double h = 0;

  ///width
  ///
  double w = 0;

  ///horizontal
  ///
  double x = 0;

  ///vertical
  ///
  double y = 0;

  ///timer for animation hole overlay
  ///
  Timer? timer;

  ///init state
  ///
  @override
  void initState() {
    super.initState();
    start();
  }

  ///dispose
  ///

  late Duration _duration;

  @override
  void dispose() {
    if (null != timer) {
      timer!.cancel();
    }
    super.dispose();
  }

  ///start method (animation, show, etc)
  ///
  void start() async {
    _duration = widget.duration ?? Duration(seconds: 1);

    await Future.delayed(Duration(milliseconds: 100));

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

    ///show card
    ///
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
          colorFilter: ColorFilter.mode(
            widget.veilColor,
            BlendMode.srcOut,
          ),
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
                height: h == 0 ? MediaQuery.of(context).size.height : h,
                width: w == 0 ? MediaQuery.of(context).size.width : w,
                duration: _duration,
                curve: Curves.fastOutSlowIn,
                child: GestureDetector(
                  onTap: () async {
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
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius)),
                  ),
                ),
              ),
            ],
          ),
        ),
        WidgetCard(
          duration: _duration,
          x: x,
          y: y,
          h: h,
          w: w,
          enable: enable,
          model: widget.model,
          buttonOptions: widget.buttonOptions,
          // onSkip: widget.onSkip,

          onSkip: () async {
            await _closeTooltip();
          },

          onTapNext: () async {
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
        x = 0;
        y = 0;
      });
      await Future.delayed(_duration);

      widget.onTapNext!();
    }
  }
}
