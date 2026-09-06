/// Aura Pregnancy - Doğum Çantası Eşya Modeli
class HospitalBagItem {
  final int? id;
  final String category; // 'mom', 'baby', 'partner'
  final String title;
  final bool isPacked;
  final bool isCustom;
  final int quantity;

  const HospitalBagItem({
    this.id,
    required this.category,
    required this.title,
    this.isPacked = false,
    this.isCustom = false,
    this.quantity = 1,
  });

  HospitalBagItem copyWith({
    int? id,
    String? category,
    String? title,
    bool? isPacked,
    bool? isCustom,
    int? quantity,
  }) {
    return HospitalBagItem(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      isPacked: isPacked ?? this.isPacked,
      isCustom: isCustom ?? this.isCustom,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'category': category,
      'title': title,
      'is_packed': isPacked ? 1 : 0,
      'is_custom': isCustom ? 1 : 0,
      'quantity': quantity,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory HospitalBagItem.fromMap(Map<String, dynamic> map) {
    return HospitalBagItem(
      id: map['id'] as int?,
      category: map['category'] as String,
      title: map['title'] as String,
      isPacked: (map['is_packed'] as int? ?? 0) == 1,
      isCustom: (map['is_custom'] as int? ?? 0) == 1,
      quantity: map['quantity'] as int? ?? 1,
    );
  }
}
