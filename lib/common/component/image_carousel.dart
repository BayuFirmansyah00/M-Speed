import 'package:flutter/material.dart';
import 'package:mspeed/common/component/custom_navigator.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/common/helper/safe_network_image.dart';
import 'package:mspeed/generated/assets.dart';

import '../../src/buyer/product/view/product_viewer.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  bool isMiniPreview;
  ImageCarousel({Key? key, required this.imageUrls, this.isMiniPreview = false})
      : super(key: key);

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index % widget.imageUrls.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.isMiniPreview ? 400 : 250,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        CusNav.nPush(context, ProductViewer());
                      },
                      child: Image.network(
                        widget.imageUrls[index % widget.imageUrls.length],
                        fit: BoxFit.cover,
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                      ),
                    );
                  },
                  onPageChanged: _onPageChanged,
                ),
                Positioned(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFFEEF0F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0XFF6D7588)),
                    ),
                    child:
                        Text('${_currentIndex + 1}/${widget.imageUrls.length}'),
                  ),
                  right: 16,
                  bottom: 16,
                )
              ],
            ),
          ),
          if (widget.isMiniPreview)
            Container(
              height: 75,
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.only(top: 10),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (c, i) {
                  return InkWell(
                    onTap: () async {
                      setState(() {
                        _currentIndex = i;
                      });
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          SafeNetworkImage(
                            width: 70,
                            height: 70,
                            url:  widget.imageUrls[i],
                            errorBuilder:
                                Image.asset(Assets.imagesImgHeadphone),
                          ),
                          if (_currentIndex != i)
                            Container(
                              width: 70,
                              height: 70,
                              color: Colors.white.withOpacity(0.7),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => Constant.xSizedBox10,
                itemCount: widget.imageUrls.length,
              ),
            ),
        ],
      ),
    );
  }
}
