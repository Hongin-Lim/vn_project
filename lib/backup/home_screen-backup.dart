// import 'package:flutter/material.dart';
// import 'package:vn_project/screens/product_detail_screen.dart';
//
// import '../screens/place_holder_screen.dart';
//
// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0; // BottomNavigationBar 상태
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size; // 화면 크기 정보
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('BeautiQ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             Icon(Icons.search, size: 28),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 이벤트 슬라이드 배너
//             EventBanner(size: size),
//             SizedBox(height: 20),
//
//             // 카테고리 섹션
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 'Danh mục',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(height: 10),
//             CategorySection(size: size),
//
//             // 추천 상품 섹션
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 'Sản phẩm đề xuất',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ),
//             SizedBox(height: 10),
//             ProductSection(size: size),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
//           BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Yêu thích'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
//         ],
//       ),
//     );
//   }
// }
//
// class EventBanner extends StatefulWidget {
//   final Size size;
//
//   const EventBanner({required this.size});
//
//   @override
//   _EventBannerState createState() => _EventBannerState();
// }
//
// class _EventBannerState extends State<EventBanner> {
//   int _currentBannerIndex = 0;
//
//   final List<String> _bannerImages = [
//     'https://hongin-lim.github.io/vn_project/images/slide-001.png',
//     'https://hongin-lim.github.io/vn_project/images/slide-002.png',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         SizedBox(
//           height: widget.size.width * 9 / 16, // 반응형 16:9 비율
//           child: PageView.builder(
//             onPageChanged: (index) {
//               setState(() {
//                 _currentBannerIndex = index;
//               });
//             },
//             itemCount: _bannerImages.length,
//             itemBuilder: (context, index) {
//               return Image.network(
//                 _bannerImages[index],
//                 fit: BoxFit.cover,
//               );
//             },
//           ),
//         ),
//         SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(
//             _bannerImages.length,
//                 (index) => Container(
//               margin: EdgeInsets.symmetric(horizontal: 4),
//               width: _currentBannerIndex == index ? 12 : 8,
//               height: _currentBannerIndex == index ? 12 : 8,
//               decoration: BoxDecoration(
//                 color: _currentBannerIndex == index ? Colors.blue : Colors.grey,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class CategorySection extends StatelessWidget {
//   final Size size;
//
//   const CategorySection({required this.size});
//
//   final List<Map<String, dynamic>> _categories = [
//     {'name': 'Tất cả', 'icon': Icons.all_inclusive},
//     {'name': 'Chăm sóc da', 'icon': Icons.face_4},
//     {'name': 'Trang điểm', 'icon': Icons.brush},
//     {'name': 'Tẩy trang', 'icon': Icons.water_drop},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: size.height * 0.15, // 반응형 높이
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         scrollDirection: Axis.horizontal,
//         itemCount: _categories.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => PlaceholderScreen(
//                     title: _categories[index]['name'],
//                   ),
//                 ),
//               );
//             },
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundColor: Colors.blue,
//                     child: Icon(
//                       _categories[index]['icon'],
//                       size: size.width * 0.05, // 반응형 아이콘 크기
//                       color: Colors.white,
//                     ),
//                   ),
//                   SizedBox(height: 8),
//                   Text(
//                     _categories[index]['name'],
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: size.width * 0.03),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class ProductSection extends StatelessWidget {
//   final Size size;
//
//   const ProductSection({required this.size});
//
//   final List<Map<String, String>> _products = [
//     {'id': '1', 'name': 'Torriden Serum', 'price': '\đ 120,000', 'image': 'https://hongin-lim.github.io/vn_project/images/products/torriden.jpg'},
//     {'id': '2', 'name': 'Bioderma', 'price': '\đ 400,000', 'image': 'https://hongin-lim.github.io/vn_project/images/products/bioderma.jpg'},
//     {'id': '3', 'name': 'goodal Serum', 'price': '\đ 70,000', 'image': 'https://hongin-lim.github.io/vn_project/images/products/goodal2.jpg'},
//     {'id': '4', 'name': 'Wellage AMPOULE', 'price': '\đ 550,000', 'image': 'https://hongin-lim.github.io/vn_project/images/products/wellage.jpg'},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return GridView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: size.width > 600 ? 3 : 2, // 넓은 화면에선 3열
//         childAspectRatio: size.width > 600 ? 0.8 : 0.7,
//         mainAxisSpacing: 16,
//         crossAxisSpacing: 16,
//       ),
//       itemCount: _products.length,
//       itemBuilder: (context, index) {
//         final product = _products[index];
//         return GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: product['id']!)),
//             );
//           },
//           child: Column(
//             children: [
//               Expanded(
//                 child: Image.network(
//                   product['image']!,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               SizedBox(height: 8),
//               Text(product['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
//               Text(product['price']!),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
