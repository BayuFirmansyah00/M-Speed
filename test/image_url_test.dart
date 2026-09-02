import 'package:flutter_test/flutter_test.dart';
import 'package:mspeed/common/helper/constant.dart';

String resolveImageUrl(String? rawUrl) {
  if (rawUrl == null || rawUrl.trim().isEmpty) return '';
  var url = rawUrl.trim();

  // Fix wrong storage prefix for public assets
  if (url.contains('/storage/asset_img_backend/')) {
    url = url.replaceAll('/storage/asset_img_backend/', '/asset_img_backend/');
  }

  // Derive base origin from Constant.BASE_API_FULL (e.g. "http://10.0.2.2:8000" or "https://mspeed.mitrakaryaprima.com")
  final baseApi = Constant.BASE_API_FULL;
  final baseOrigin = baseApi.replaceAll(RegExp(r'/api/?$'), '');

  // If URL uses localhost or 127.0.0.1 without port or on dev machine
  final localhostRegex = RegExp(r'^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?');
  if (localhostRegex.hasMatch(url)) {
    url = url.replaceFirst(localhostRegex, baseOrigin);
  } else if (!url.startsWith('http://') && !url.startsWith('https://')) {
    final cleanPath = url.startsWith('/') ? url : '/$url';
    url = '$baseOrigin$cleanPath';
  }

  return url;
}

void main() {
  test('resolveImageUrl transforms URLs correctly', () {
    expect(
      resolveImageUrl('http://localhost/storage/asset_img_backend/documentation.png'),
      'http://10.0.2.2:8000/asset_img_backend/documentation.png',
    );
    expect(
      resolveImageUrl('http://localhost/storage/products/item1.jpg'),
      'http://10.0.2.2:8000/storage/products/item1.jpg',
    );
    expect(
      resolveImageUrl('/storage/products/item1.jpg'),
      'http://10.0.2.2:8000/storage/products/item1.jpg',
    );
    expect(
      resolveImageUrl('https://picsum.photos/300/300'),
      'https://picsum.photos/300/300',
    );
    expect(
      resolveImageUrl(''),
      '',
    );
  });
}
