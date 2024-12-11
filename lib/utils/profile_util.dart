class ProfileUtils {
  static const List<Map<String, String>> genderOptions = [
    {'key': 'Male', 'label': 'Nam(남성)'},
    {'key': 'Female', 'label': 'Nữ(여성)'},
    {'key': 'Other', 'label': 'Khác(기타)'},
  ];

  static const List<Map<String, String>> regionOptions = [
    {'key': 'Vietnam', 'label': 'Việt Nam(베트남)'},
    {'key': 'Korea', 'label': 'Hàn Quốc(한국)'},
  ];

  static const List<Map<String, String>> skinTypeOptions = [
    {'key': 'Da dầu', 'label': 'Da dầu(지성)'},
    {'key': 'Da khô', 'label': 'Da khô(건성)'},
    {'key': 'Da hỗn hợp', 'label': 'Da hỗn hợp(복합성)'},
    {'key': 'Da nhạy cảm', 'label': 'Da nhạy cảm(민감성)'},
    {'key': 'Da thường', 'label': 'Da thường(중성)'},
  ];

  static const List<Map<String, String>> skinConditionsOptions = [
    {'key': 'Mụn', 'label': 'Mụn(여드름)'},
    {'key': 'Mẩn đỏ', 'label': 'Mẩn đỏ(홍조)'},
    {'key': 'Nếp nhăn', 'label': 'Nếp nhăn(주름)'},
    {'key': 'Đốm nâu', 'label': 'Đốm nâu(잡티)'}
  ];

  static const List<String> iconOptions = [
    '👩', '👨', '👶', '🧑‍🎨', '👩‍🔧',
    '💄', '💅', '👗', '👒', '👜',
  ];

  // 유틸리티 메서드들도 추가 가능
  static String getLabelFromKey(List<Map<String, String>> options, String key) {
    final option = options.firstWhere(
          (option) => option['key'] == key,
      orElse: () => {'key': key, 'label': key},
    );
    return option['label'] ?? key;
  }

  static String getKeyFromLabel(List<Map<String, String>> options, String label) {
    final option = options.firstWhere(
          (option) => option['label'] == label,
      orElse: () => {'key': label, 'label': label},
    );
    return option['key'] ?? label;
  }
}