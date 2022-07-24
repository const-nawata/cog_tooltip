import 'package:cog_tooltip/src/models/coach_button_model.dart';
import 'package:cog_tooltip/src/models/coach_model.dart';
import 'package:flutter/material.dart';

class WidgetCard extends StatefulWidget {
  final double x, y, h, w;
  final bool enable;
  final Widget? child;
  final CoachModel model;
  final CoachButtonOptions? buttonOptions;
  final Function()? onSkip;
  final Function()? onTapNext;
  final Duration duration;

  const WidgetCard(
      {Key? key,
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
      this.onTapNext})
      : super(key: key);

  @override
  WidgetCardState createState() => WidgetCardState();
}

class WidgetCardState extends State<WidgetCard> {
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

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left:
          MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
              ? 0
              : x + w < (MediaQuery.of(context).size.width / 2)
                  ? h > hCard
                      ? x - (w / 2) + 8
                      : (x + w * -1) - 8
                  : (x < (MediaQuery.of(context).size.width / 2)
                      ? h > hCard
                          ? x + w + wCard > MediaQuery.of(context).size.width
                              ? x - wCard
                              : x - (w / 2) + 8
                          : 0
                      : x - w - (w / 2) - wCard - 16),
      top:
          MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
              ? y + h + hCard + (widget.model.subtitle!.length == 1 ? 0 : 50) >
                      MediaQuery.of(context).size.height
                  ? y - hCard - (widget.model.subtitle!.length == 1 ? 24 : 16)
                  : y + h + 24
              : y > MediaQuery.of(context).size.height / 2
                  ? y - hCard - (widget.model.subtitle!.length == 1 ? 24 : 16)
                  : y < (MediaQuery.of(context).size.height / 2)
                      ? y + h > hCard
                          ? y
                          : y + h + 8
                      : x < (MediaQuery.of(context).size.width / 2)
                          ? y
                          : y + h + 8,
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
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Container(
                  width: widget.model.maxWidth ??
                      MediaQuery.of(context).size.width - 80,
                  key: const GlobalObjectKey('pointWidget1234567890'),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
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
                              Text(
                                '${widget.model.title}',
                                style: const TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold),
                              ),
                              widget.model.subtitle!.length == 1
                                  ? Text(
                                      '${widget.model.subtitle!.first}',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 100,
                                      style: const TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500),
                                    )
                                  : SizedBox(
                                      height: 50,
                                      child: ScrollConfiguration(
                                        behavior: MyBehavior(),
                                        child: PageView.builder(
                                            onPageChanged: (x) {
                                              setState(() {
                                                currentPage = x;
                                              });
                                            },
                                            controller: pageController,
                                            itemCount:
                                                widget.model.subtitle!.length,
                                            itemBuilder: (context, index) {
                                              return Text(
                                                '${widget.model.subtitle![index]}',
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 12.0,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.w500),
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
                                              widget.model.subtitle!.length,
                                              (index) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 3),
                                                    child: Container(
                                                      height: 5,
                                                      width: 5,
                                                      decoration: BoxDecoration(
                                                          color: index ==
                                                                  currentPage
                                                              ? Colors.black87
                                                              : Colors.grey,
                                                          shape:
                                                              BoxShape.circle),
                                                    ),
                                                  )),
                                        ),
                                  Row(
                                    children: [
                                      widget.onSkip == null
                                          ? const SizedBox()
                                          : MaterialButton(
                                              onPressed: widget.onSkip,
                                              child: Text(
                                                '${widget.buttonOptions!.skipTitle}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                      const SizedBox(width: 5.0),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (widget.model.subtitle!.length ==
                                                  1 ||
                                              pageController.hasClients) {
                                            if (currentPage + 1 ==
                                                widget.model.subtitle!.length) {
                                              if (widget.model
                                                      .nextOnTapCallBack !=
                                                  null) {
                                                bool result = await widget
                                                    .model.nextOnTapCallBack!
                                                    .call();

                                                if (result) {
                                                  widget.onTapNext!();

                                                  if (pageController
                                                      .hasClients) {
                                                    pageController
                                                        .animateToPage(
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

                                              if (widget.model.scrollOptions !=
                                                  null) {
                                                if (widget.model.scrollOptions!
                                                        .isLast ==
                                                    true) {
                                                  scrollToIndex(index: 0);

                                                  await Future.delayed(
                                                      widget.duration);
                                                } else {
                                                  if (widget
                                                          .model
                                                          .scrollOptions!
                                                          .manualHeight !=
                                                      null) {
                                                    scrollToIndex(
                                                        manualHeight: widget
                                                            .model
                                                            .scrollOptions!
                                                            .manualHeight);
                                                  } else {
                                                    scrollToIndex(
                                                        index: widget
                                                            .model
                                                            .scrollOptions!
                                                            .scrollToIndex!);
                                                  }

                                                  await Future.delayed(
                                                      widget.duration);
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
                                        style:
                                            widget.buttonOptions!.buttonStyle,
                                        child: Text(
                                          '${widget.buttonOptions!.buttonTitle}',
                                        ),
                                      ),
                                    ],
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
