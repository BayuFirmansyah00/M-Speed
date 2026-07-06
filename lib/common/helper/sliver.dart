// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';

// class SliverCustom extends StatefulWidget {
//   final ScrollController controller;
//   final ScrollPhysics physics;
//   final String appBarText;
//   final Widget banner;
//   final Widget info;
//   final CarouselController carouselController;
//   final bool sliverCollapsed;
//   final Function(int index, CarouselPageChangedReason reason)? onPageChanged;

//   final double expandedHeight;

//   /// Changes edge behavior to account for [SliverAppBar.pinned].
//   ///
//   /// Hides the edge when the [ScrollController.offset] reaches the collapsed
//   /// height of the [SliverAppBar] to prevent it from overlapping the app bar.
//   final bool hasPinnedAppBar;

//   SliverCustom({
//     required this.expandedHeight,
//     required this.controller,
//     required this.physics,
//     this.hasPinnedAppBar = false,
//     required this.appBarText,
//     required this.banner,
//     required this.info,
//     required this.carouselController,
//     required this.sliverCollapsed,
//     this.onPageChanged,
//   }) {
//     assert(expandedHeight != null);
//     assert(hasPinnedAppBar != null);
//   }

//   @override
//   _SliverCustomState createState() => _SliverCustomState();
// }

// class _SliverCustomState extends State<SliverCustom> {
//   late ScrollController ctrl;

//   @override
//   void initState() {
//     super.initState();

//     ctrl = widget.controller ?? ScrollController();
//     ctrl.addListener(() => setState(() {}));
//   }

//   @override
//   void dispose() {
//     if (widget.controller == null) {
//       ctrl.dispose();
//     }

//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: <Widget>[
//         CustomScrollView(
//           controller: ctrl,
//           physics: widget.physics,
//           slivers: [
//             SliverAppBar(
//               bottom: PreferredSize(
//                 preferredSize: const Size.fromHeight(24),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: const BoxDecoration(
//                     borderRadius: BorderRadius.vertical(
//                       top: Radius.circular(12),
//                     ),
//                     color: Colors.white,
//                   ),
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10),
//                         child: Container(),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               pinned: true,
//               floating: true,
//               expandedHeight: widget.expandedHeight,
//               flexibleSpace: FlexibleSpaceBar(
//                 expandedTitleScale: 1.1,
//                 titlePadding: const EdgeInsets.fromLTRB(0, 8, 0, 48),
//                 background: widget.banner,
//                 stretchModes: const <StretchMode>[
//                   StretchMode.zoomBackground,
//                   // StretchMode.blurBackground,
//                   // StretchMode.fadeTitle,
//                 ],
//               ),
//               backgroundColor: Colors.white,
//               automaticallyImplyLeading: false,
//               leading: InkWell(
//                 onTap: () => Navigator.pop(context),
//                 child: Padding(
//                   padding: const EdgeInsets.only(left: 8),
//                   child: Icon(
//                     Icons.arrow_back,
//                     color:
//                         !widget.sliverCollapsed ? Colors.white : Colors.black,
//                     // size: 32,
//                   ),
//                 ),
//               ),
//               centerTitle: true,
//               title: Text(widget.appBarText,
//                   style: TextStyle(
//                       color: !widget.sliverCollapsed
//                           ? Colors.white
//                           : Colors.black)),
//             ),
//             // SliverFillRemaining(child: widget.info),
//             SliverList(delegate: SliverChildListDelegate([widget.info])),
//           ],
//         ),
//         // _buildEdge(),
//       ],
//     );
//   }

//   _buildEdge() {
//     var edgeHeight = 12.0;
//     var paddingTop = MediaQuery.of(context).padding.top;

//     var defaultOffset = (paddingTop + widget.expandedHeight) - edgeHeight;

//     var top = defaultOffset;
//     var edgeSize = edgeHeight;

//     if (ctrl.hasClients) {
//       double offset = ctrl.offset;
//       top -= offset > 0 ? offset : 0;

//       if (widget.hasPinnedAppBar) {
//         // Hide edge to prevent overlapping the toolbar during scroll.
//         var breakpoint = widget.expandedHeight - kToolbarHeight - edgeHeight;

//         if (offset >= breakpoint) {
//           edgeSize = edgeHeight - (offset - breakpoint);
//           if (edgeSize < 0) {
//             edgeSize = 0;
//           }

//           top += (edgeHeight - edgeSize);
//         }
//       }
//     }

//     return Positioned(
//       top: top,
//       left: 0,
//       right: 0,
//       child: Container(
//         height: edgeSize,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border.all(color: Colors.white),
//           borderRadius: BorderRadius.vertical(
//             top: Radius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }
