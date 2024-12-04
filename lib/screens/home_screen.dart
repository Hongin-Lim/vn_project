import 'package:flutter/material.dart';

import 'product_list_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // BottomNavigationBar 상태

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('BeautiQ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Icon(Icons.search, size: 28),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이벤트 슬라이드 배너
            EventBanner(),
            SizedBox(height: 20),

            // 카테고리 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            CategorySection(),

            // 추천 상품 섹션
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recommended Products',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            ProductSection(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class EventBanner extends StatefulWidget {
  @override
  _EventBannerState createState() => _EventBannerState();
}

class _EventBannerState extends State<EventBanner> {
  int _currentBannerIndex = 0;

  // 새 이미지 경로로 리스트 업데이트
  final List<String> _bannerImages = [
    'https://hongin-lim.github.io/vn_project/images/slide-001.png',
    'https://hongin-lim.github.io/vn_project/images/slide-002.png',
    // 'https://hongin-lim.github.io/vn_project/images/event3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9, // 슬라이드 비율 (16:9)
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _bannerImages.length,
            itemBuilder: (context, index) {
              return Image.network(
                _bannerImages[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _bannerImages.length,
                (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 12 : 8,
              height: _currentBannerIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class CategorySection extends StatelessWidget {
  final List<String> _categories = ['Electronics', 'Fashion', 'Home', 'Beauty', 'Toys'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  child: Text(
                    _categories[index][0],
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                SizedBox(height: 8),
                Text(_categories[index]),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ProductSection extends StatelessWidget {
  final List<Map<String, String>> _products = [
    {'name': 'Product 1', 'price': '\$100', 'image': 'https://via.placeholder.com/100'},
    {'name': 'Product 2', 'price': '\$200', 'image': 'https://via.placeholder.com/100'},
    {'name': 'Product 3', 'price': '\$300', 'image': 'https://via.placeholder.com/100'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductListScreen()),
            );
          },
          child: Column(
            children: [
              Expanded(
                child: Image.network(
                  product['image']!,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8),
              Text(product['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(product['price']!),
            ],
          ),
        );
      },
    );
  }
}
