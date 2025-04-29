import 'package:flutter/cupertino.dart';

class DownOnlyScrollView extends StatefulWidget {
  final Widget child;
  const DownOnlyScrollView({super.key, required this.child});

  @override
  State<DownOnlyScrollView> createState() => _DownOnlyScrollViewState();
}

class _DownOnlyScrollViewState extends State<DownOnlyScrollView> {
  final _scrollController = ScrollController();
  bool isScrollable = false;

  @override
  void initState() {
    super.initState();
    addScrollListener();
  }

  void addScrollListener() {
    _scrollController.addListener(() {
      bool isTop = false;
      if (_scrollController.position.atEdge) {
        isTop = _scrollController.position.pixels == 0;
        if (isTop) {
          // _scrollController.
          setState(() {
            isScrollable = false;
          });
        } else {
          print('At the bottom');
        }
      }
      if (!isTop) {
        setState(() {
          isScrollable = true;
        });
      }
      // isScrollable = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          print(
              "axis: ${scrollInfo.metrics.axis} pixels: ${scrollInfo.metrics.pixels}");
          return false;
        },
        child: SingleChildScrollView(
            controller: _scrollController,
            physics: isScrollable ? null : NeverScrollableScrollPhysics(),
            child: widget.child));
  }
}

//  GestureDetector(
//             behavior: HitTestBehavior.opaque,
//             onPanUpdate: (details) {
//               if (details.delta.dy > 0) {
//                 setState(() {
//                   isScrollable = true;
//                 });
//               }
//               if (details.delta.dy < 0) {
//                 // set your var
//                 isScrollable = false;
//               }
//             },
