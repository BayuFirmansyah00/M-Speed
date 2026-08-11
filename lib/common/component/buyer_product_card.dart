import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'package:mspeed/utils/utils.dart';
import 'package:mspeed/common/component/image_network_widget.dart';

class BuyerProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String sellerName;
  final String category;
  final double rating;
  final int soldCount;
  final double price;
  final bool isNew;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;
  final VoidCallback onAddToCartTap;

  const BuyerProductCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.sellerName,
    required this.category,
    required this.rating,
    required this.soldCount,
    required this.price,
    this.isNew = false,
    this.isWishlisted = false,
    required this.onTap,
    required this.onWishlistTap,
    required this.onAddToCartTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180, // Diperkecil sangat drastis (dari 220)
        decoration: BoxDecoration(
          color: Constant.dsSurface,
          borderRadius: BorderRadius.circular(Constant.radiusSm), // 8px
          border: Border.all(color: Constant.dsBorder, width: 1),
          boxShadow: [Constant.shadowSmall], // Bayangan lebih tipis
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image & Badges (Height 100px)
            SizedBox(
              height: 100, // Diperkecil dari 120
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(Constant.radiusSm)),
                    child: ImageNetworkWidget(
                      imageUrl: imageUrl,
                      boxFit: BoxFit.cover,
                      width: double.infinity,
                      height: 100,
                    ),
                  ),
                  // Badge Baru/Promo di Top-Left
                  if (isNew)
                    Positioned(
                      top: Constant.space8,
                      left: Constant.space8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Constant.dsAccent, // Kuning Aksen
                          borderRadius: BorderRadius.circular(Constant.radiusXs),
                        ),
                        child: Text(
                          'BARU',
                          style: TextStyle(
                            color: Constant.dsSurface,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: Constant.primaryTextStyle.fontFamily,
                          ),
                        ),
                      ),
                    ),
                  // Favorite Icon di Top-Right
                  Positioned(
                    top: Constant.space4,
                    right: Constant.space4,
                    child: IconButton(
                      icon: Icon(
                        isWishlisted ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        color: isWishlisted ? Constant.dsSecondary : Constant.dsTextSecondary,
                        size: 20,
                      ),
                      onPressed: onWishlistTap,
                    ),
                  ),
                ],
              ),
            ),
            
            // 2. Details Container
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0), // Padding dipertipis (dari 8)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name (Max 2 lines)
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: Constant.primaryTextStyle.fontFamily,
                        fontSize: 10, // Diperkecil dari 11
                        fontWeight: FontWeight.w600,
                        color: Constant.dsTextPrimary,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 1.0),
                    
                    // Seller
                    Text(
                      sellerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: Constant.primaryTextStyle.fontFamily,
                        fontSize: 9, // Diperkecil dari 10
                        color: Constant.dsTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 1.0),
                    
                    // Rating & Sold (Satu Baris)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.star_rounded, color: Constant.dsAccent, size: 10), // Bintang sangat kecil
                        const SizedBox(width: 2.0),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: Constant.primaryTextStyle.fontFamily,
                            fontSize: 9, // Diperkecil
                            color: Constant.dsTextSecondary,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '|',
                          style: TextStyle(color: Constant.dsDivider, fontSize: 9),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          '$soldCount terjual',
                          style: TextStyle(
                            fontFamily: Constant.primaryTextStyle.fontFamily,
                            fontSize: 9, // Diperkecil
                            color: Constant.dsTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Price & Cart Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            Utils.formatCurrency(price),
                            style: TextStyle(
                              fontFamily: Constant.primaryTextStyle.fontFamily,
                              fontSize: 11, // Diperkecil dari 12
                              fontWeight: FontWeight.bold,
                              color: Constant.dsSecondary, // Harga = Merah
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onAddToCartTap,
                          borderRadius: BorderRadius.circular(Constant.radiusXs), // 4px
                          child: Container(
                            padding: const EdgeInsets.all(4.0), // Padding keranjang lebih tipis
                            decoration: BoxDecoration(
                              color: Constant.dsPrimary, // Cart = Biru
                              borderRadius: BorderRadius.circular(Constant.radiusXs),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              color: Colors.white,
                              size: 14, // Icon keranjang lebih kecil
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
