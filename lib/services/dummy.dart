import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeFirestore() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Users 초기화
  final users = [
    {
      "email": "user1@example.com",
      "username": "beautylover1",
      "profileImageUrl": "https://hongin-lim.github.io/vn_project/images/products/goodal.jpg",
      "createdAt": FieldValue.serverTimestamp(),
      "lastLoginAt": FieldValue.serverTimestamp(),
      "likedReviews": ["review1", "review3"]
    },
    // 추가 유저...
  ];

  List<DocumentReference> userRefs = [];
  for (var user in users) {
    final docRef = await firestore.collection('users').add(user);
    userRefs.add(docRef); // 각 유저의 참조를 리스트에 저장
  }

  // Products 초기화
  final products = [
    {
      "name": "Hydrating Serum",
      "description": "A lightweight serum that hydrates and nourishes your skin.",
      "imageUrl": "https://hongin-lim.github.io/vn_project/images/products/torriden.jpg",
      "category": "Skincare",
      "reviewCount": 2,
      "averageRating": 4.5
    },
    // 추가 제품...
  ];

  List<DocumentReference> productRefs = [];
  for (var product in products) {
    final docRef = await firestore.collection('products').add(product);
    productRefs.add(docRef); // 각 제품의 참조를 리스트에 저장
  }

  // Reviews 초기화
  // final reviews = [
  //   {
  //     "productId": productRefs[0].id, // 첫 번째 제품의 ID 사용
  //     "userId": userRefs[0].id, // 첫 번째 유저의 ID 사용
  //     "title": "Amazing Product",
  //     "content": "This serum is amazing! It keeps my skin hydrated all day.",
  //     "rating": 5,
  //     "imageUrls": [
  //       "gs://vn-project-bed5c.firebasestorage.app/bioderma.jpg",
  //       "gs://vn-project-bed5c.firebasestorage.app/wellage.jpg"
  //     ],
  //     "createdAt": FieldValue.serverTimestamp(),
  //   },
  //   // 추가 리뷰...
  // ];

  // for (var review in reviews) {
  //   await firestore.collection('reviews').add(review);
  // }
}
