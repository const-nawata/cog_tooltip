import 'dart:async';

import 'package:cog_tooltip/src/models/coach_button_model.dart';
import 'package:cog_tooltip/src/models/coach_model.dart';
import 'package:cog_tooltip/src/widgets/widget_card.dart';
import 'package:flutter/material.dart';

class WidgetMain extends StatefulWidget {
  final double x, y, h, w, padding, borderRadius;
  final CoachModel model;
  final CoachButtonOptions? buttonOptions;
  final Duration duration;

  final Function()? onSkip;
  final Function()? onTapNext;

  const WidgetMain(
      {Key? key,
      required this.x,
      required this.y,
      required this.h,
      required this.w,
      this.padding = 8,
      this.borderRadius = 5,
      required this.duration,
      this.onSkip,
      this.onTapNext,
      this.buttonOptions,
      required this.model})
      : super(key: key);

  @override
  WidgetMainState createState() => WidgetMainState();
}

class WidgetMainState extends State<WidgetMain> {
  bool enable = false;
  double h = 0;
  double w = 0;
  double x = 0;
  double y = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  void start() async {
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      h = widget.h + (widget.padding * 2);
      w = widget.w + (widget.padding * 2);
      x = widget.x - widget.padding;
      y = widget.y - widget.padding;
    });

    timer = Timer.periodic(widget.duration, (Timer t) {
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

    await Future.delayed(widget.duration);

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
          colorFilter:
              ColorFilter.mode(Colors.black.withOpacity(0.8), BlendMode.srcOut),
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () {
                  // removeOverlay();
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
              ),
              AnimatedPositioned(
                left: x,
                top: y,
                height: h == 0 ? MediaQuery.of(context).size.height : h,
                width: w == 0 ? MediaQuery.of(context).size.width : w,
                duration: widget.duration,
                curve: Curves.fastOutSlowIn,
                child: GestureDetector(
                  // TODO: Remove?
                  // onTap: () async {},
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
          duration: widget.duration,
          x: x,
          y: y,
          h: h,
          w: w,
          enable: enable,
          model: widget.model,
          buttonOptions: widget.buttonOptions,
          onSkip: widget.onSkip,
          onTapNext: () async {
            if (enable) {
              setState(() {
                enable = false;
              });
              timer!.cancel();
              setState(() {
                h = MediaQuery.of(context).size.height;
                w = MediaQuery.of(context).size.width;
                x = 0;
                y = 0;
              });
              await Future.delayed(widget.duration);

              widget.onTapNext!();
            }
          },
        )
      ],
    );
  }
}
