import 'package:cog_tooltip/cog_tooltip.dart';
import 'package:flutter/material.dart';

class TooltipBody extends StatefulWidget {
  final double x, y, h, w;
  final bool enable;
  final Widget? child;
  final CoachModel model;
  final CoachButtonOptions? buttonOptions;
  final Function()? onSkip;
  final Function()? onTapNext;
  final Duration duration;
  final double cogPosition;
  final double lrShift;
  final int titleColor;
  final int subTitleColor;

  const TooltipBody({
    Key? key,
    required this.enable,
    required this.x,
    required this.y,
    required this.h,
    required this.w,
    required this.model,
    required this.duration,
    this.buttonOptions,
    this.child,
    this.onSkip,
    this.onTapNext,
    this.cogPosition = 0.0,
    this.lrShift = 0.0,
    this.titleColor = 0xFF000000,
    this.subTitleColor = 0xFF000000,
  }) : super(key: key);

  @override
  TooltipBodyState createState() => TooltipBodyState();
}

class TooltipBodyState extends State<TooltipBody> {
  double top = 0;
  double h = 0;
  double w = 0;
  double x = 0;
  double y = 0;
  double hCard = 0;
  double wCard = 0;
  int currentPage = 0;

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void start() async {
    Future.delayed(Duration.zero, () {
      RenderBox box = const GlobalObjectKey('pointWidget1234567890')
          .currentContext!
          .findRenderObject() as RenderBox;

      setState(() {
        hCard = box.size.height;
        wCard = box.size.width;
      });
    });

    await Future.delayed(widget.duration);

    setState(() {
      x = widget.x;
      y = widget.y;
      h = widget.h;
      w = widget.w;
      top = x + h + 24;
    });
  }

  void scrollToIndex({int index = 0, double? manualHeight}) {
    if (manualHeight != null) {
      widget.model.scrollOptions!.scrollController!.animateTo(manualHeight,
          duration: widget.duration, curve: Curves.ease);
    } else {
      if (index == 0) {
        widget.model.scrollOptions!.scrollController!
            .animateTo(0, duration: widget.duration, curve: Curves.ease);
      } else {
        RenderBox box = GlobalObjectKey(widget.model.initial!)
            .currentContext!
            .findRenderObject() as RenderBox;

        widget.model.scrollOptions!.scrollController!.animateTo(
            box.size.height * index,
            duration: widget.duration,
            curve: Curves.ease);
      }
    }
  }

  double _maxWidth = 250.0;

  @override
  Widget build(BuildContext context) {
    bool isAbove =
        (y + h + hCard + (widget.model.subtitle!.length == 1 ? 0 : 50) >
            MediaQuery.of(context).size.height);

    _maxWidth =
        (widget.model.maxWidth ?? MediaQuery.of(context).size.width - 80.0);

    return Positioned(
      left: widget.lrShift,
      top: isAbove
          ? y - hCard - (widget.model.subtitle!.length == 1 ? 24 : 16)
          : y + h + 15,
      child: Material(
        color: Colors.transparent,
        child: AnimatedOpacity(
          duration: widget.duration,
          opacity: top == 0
              ? 0
              : widget.enable
                  ? 1
                  : 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Align(
              alignment: widget.model.alignment!,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: GestureDetector(
                  onTap: () async {
                    if (widget.model.subtitle!.length == 1 ||
                        pageController.hasClients) {
                      if (currentPage + 1 == widget.model.subtitle!.length) {
                        if (widget.model.nextOnTapCallBack != null) {
                          bool result =
                              await widget.model.nextOnTapCallBack!.call();

                          if (result) {
                            widget.onTapNext!();

                            if (pageController.hasClients) {
                              pageController.animateToPage(
                                0,
                                duration: widget.duration,
                                curve: Curves.easeInOut,
                              );
                            }
                          }
                        } else {
                          widget.onTapNext!();

                          if (pageController.hasClients) {
                            pageController.animateToPage(
                              0,
                              duration: widget.duration,
                              curve: Curves.easeInOut,
                            );
                          }
                        }

                        if (widget.model.scrollOptions != null) {
                          if (widget.model.scrollOptions!.isLast == true) {
                            scrollToIndex(index: 0);

                            await Future.delayed(widget.duration);
                          } else {
                            if (widget.model.scrollOptions!.manualHeight !=
                                null) {
                              scrollToIndex(
                                  manualHeight:
                                      widget.model.scrollOptions!.manualHeight);
                            } else {
                              scrollToIndex(
                                  index: widget
                                      .model.scrollOptions!.scrollToIndex!);
                            }

                            await Future.delayed(widget.duration);
                          }
                        }
                      } else {
                        pageController.animateToPage(
                          currentPage + 1,
                          duration: widget.duration,
                          curve: Curves.easeInOut,
                        );
                      }
                    }
                  },
                  child: Column(
                    children: [
                      if (!isAbove)
                        _tooltipCog(
                          isAbove,
                          cogPosition: widget.cogPosition,
                        ),
                      Container(
                        width: _maxWidth,
                        key: const GlobalObjectKey('pointWidget1234567890'),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.model.header ?? const SizedBox(),
                              widget.model.header == null
                                  ? const SizedBox()
                                  : const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 5.0),
                                      child: Text(
                                        '${widget.model.title}',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Color(widget.titleColor),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                    ),
                                    widget.model.subtitle!.length == 1
                                        ? Text(
                                            '${widget.model.subtitle!.first}',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 100,
                                            style: TextStyle(
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.w400,
                                              letterSpacing: 0.5,
                                              height: 1.4,
                                              color:
                                                  Color(widget.subTitleColor),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 50.0,
                                            child: ScrollConfiguration(
                                              behavior: MyBehavior(),
                                              child: PageView.builder(
                                                  onPageChanged: (x) {
                                                    setState(() {
                                                      currentPage = x;
                                                    });
                                                  },
                                                  controller: pageController,
                                                  itemCount: widget
                                                      .model.subtitle!.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Text(
                                                      '${widget.model.subtitle![index]}',
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        widget.model.subtitle!.length == 1
                                            ? const SizedBox()
                                            : Row(
                                                children: List.generate(
                                                    widget
                                                        .model.subtitle!.length,
                                                    (index) => Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            right: 3.0,
                                                          ),
                                                          child: Container(
                                                            height: 5.0,
                                                            width: 5.0,
                                                            decoration: BoxDecoration(
                                                                color: index ==
                                                                        currentPage
                                                                    ? Colors
                                                                        .black87
                                                                    : Colors
                                                                        .grey,
                                                                shape: BoxShape
                                                                    .circle),
                                                          ),
                                                        )),
                                              ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isAbove)
                        _tooltipCog(
                          isAbove,
                          cogPosition: widget.cogPosition,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tooltipCog(
    bool isTop, {
    double cogPosition = 0.0,
  }) {
    double pntLeftPad = 0.0;
    double pntRightPad = 0.0;

    if (cogPosition > 0.0) {
      pntLeftPad = cogPosition;
    } else if (cogPosition < 0.0) {
      pntRightPad = -cogPosition;
    }

    return Padding(
      padding: EdgeInsets.only(left: pntLeftPad, right: pntRightPad),
      child: CustomPaint(
        size: const Size(25.0, 9.0),
        painter: TrianglePainter(isDown: isTop, color: Colors.white),
      ),
    );
  }
}

// enum PointerPosition { left, center, right }

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class TrianglePainter extends CustomPainter {
  bool isDown;
  Color color;

  TrianglePainter({this.isDown = true, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.strokeWidth = 2.0;
    paint.color = color;
    paint.style = PaintingStyle.fill;

    Path path = Path();
    if (isDown) {
      path.moveTo(0.0, -1.0);
      path.lineTo(size.width, -1.0);
      path.lineTo(size.width / 2.0, size.height);
    } else {
      path.moveTo(size.width / 2.0, 0.0);
      path.lineTo(0.0, size.height + 1);
      path.lineTo(size.width, size.height + 1);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
