import 'dart:math';
import 'package:cog_tooltip/components/tooltip_info.dart';
import 'package:cog_tooltip/components/tooltip_style.dart';
import 'package:flutter/material.dart';

class TooltipBody extends StatefulWidget {
  final double x, y, h, w;
  final bool enable;
  final Widget? child;
  final TooltipInfo info;
  final TooltipStyle? style;
  final Function() onTapClose;
  final Duration duration;

  const TooltipBody({
    Key? key,
    required this.enable,
    required this.x,
    required this.y,
    required this.h,
    required this.w,
    required this.info,
    this.style,
    required this.duration,
    this.child,
    required this.onTapClose,
  }) : super(key: key);

  @override
  TooltipBodyState createState() => TooltipBodyState();
}

class TooltipBodyState extends State<TooltipBody> {
  double top = 0.0;
  double h = 0.0;
  double w = 0.0;
  double x = 0.0;
  double y = 0.0;
  double hCard = 0.0;
  double wCard = 0.0;
  int currentPage = 0;
  PageController pageController = PageController();

  String _globalKey = '';

  final Random _rnd = Random();

  late Color _titleColor;
  late Color _subTitleColor;
  late Color _backgroundColor;

  @override
  void initState() {
    super.initState();
    _globalKey = 'globalKey${_rnd.nextInt(1000000)}globalKey';

    _titleColor = widget.style?.titleColor ?? const Color(0xFF000000);
    _subTitleColor = widget.style?.subTitleColor ?? const Color(0xFF000000);
    _backgroundColor = widget.style?.backgroundColor ?? const Color(0xFFFFFFFF);

    start();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void start() async {
    Future.delayed(Duration.zero, () {
      RenderBox box = GlobalObjectKey(_globalKey)
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

  double _maxWidth = 250.0;

  @override
  Widget build(BuildContext context) {
    bool isAbove =
        (y + h + hCard + (widget.info.subtitle!.length == 1 ? 0 : 50.0) >
            MediaQuery.of(context).size.height);

    _maxWidth =
        (widget.style?.maxWidth ?? MediaQuery.of(context).size.width - 80.0);

    return Positioned(
      left: widget.style?.tooltipShift ?? 0.0,
      top: isAbove
          ? y - hCard - (widget.info.subtitle!.length == 1 ? 24 : 16)
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
            child: GestureDetector(
              onTap: () async {
                await _closeTooltipView();
              },
              child: Container(
                color: const Color(0x00FF8888),
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        await _closeTooltipView();
                      },
                      child: Column(
                        children: [
                          if (!isAbove) _tooltipPointer(isAbove),
                          Container(
                            width: _maxWidth,
                            key: GlobalObjectKey(_globalKey),
                            decoration: BoxDecoration(
                              color: _backgroundColor,
                              borderRadius: BorderRadius.circular(
                                widget.style?.borderRadius ?? 5.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 5.0),
                                          child: Text(
                                            '${widget.info.title}',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: _titleColor,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                        ),
                                        widget.info.subtitle!.length == 1
                                            ? Text(
                                                widget.info.subtitle!.first,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 100,
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: _subTitleColor,
                                                  fontWeight: FontWeight.w400,
                                                  letterSpacing: 0.5,
                                                  height: 1.4,
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
                                                      controller:
                                                          pageController,
                                                      itemCount: widget.info
                                                          .subtitle!.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Text(
                                                          widget.info
                                                              .subtitle![index],
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
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
                                            widget.info.subtitle!.length == 1
                                                ? const SizedBox()
                                                : Row(
                                                    children: List.generate(
                                                      widget.info.subtitle!
                                                          .length,
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
                                                                  : Colors.grey,
                                                              shape: BoxShape
                                                                  .circle),
                                                        ),
                                                      ),
                                                    ),
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
                          if (isAbove) _tooltipPointer(isAbove),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tooltipPointer(bool isTop) {
    double leftPadding = 0.0;
    double rightPadding = 0.0;
    double cogShift = widget.style?.cogShift ?? 0.0;

    if (cogShift > 0.0) {
      leftPadding = cogShift;
    } else if (cogShift < 0.0) {
      rightPadding = -cogShift;
    }

    return Padding(
      padding: EdgeInsets.only(left: leftPadding, right: rightPadding),
      child: CustomPaint(
        size: const Size(25.0, 9.0),
        painter: TrianglePainter(isDown: isTop, color: _backgroundColor),
      ),
    );
  }

  Future<void> _closeTooltipView() async {
    if (widget.info.subtitle!.length == 1 || pageController.hasClients) {
      if (currentPage + 1 == widget.info.subtitle!.length) {
        widget.onTapClose();

        if (pageController.hasClients) {
          pageController.animateToPage(
            0,
            duration: widget.duration,
            curve: Curves.easeInOut,
          );
        }
      } else {
        pageController.animateToPage(
          currentPage + 1,
          duration: widget.duration,
          curve: Curves.easeInOut,
        );
      }
    }
  }
}

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
