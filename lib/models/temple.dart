class Temple {
  final String id;
  final String name;
  final String address;
  final String description;
  final String history;
  final String image;

  const Temple({
    required this.id,
    required this.name,
    required this.address,
    required this.description,
    required this.history,
    required this.image,
  });
}
const List<Temple> demoTemples = [
  Temple(
    id: 'chua-giac-lam',
    name: 'Chùa Giác Lâm',
    address: 'TP. Hồ Chí Minh',
    description:
        'Chùa Giác Lâm là một ngôi chùa cổ tại Thành phố Hồ Chí Minh.',
    history:
        'Ngôi chùa có lịch sử lâu đời và là một trong những địa điểm '
        'văn hóa Phật giáo tiêu biểu.',
    image: 'assets/images/chua_giac_lam.jpg',
  ),

  Temple(
    id: 'chua-vinh-nghiem',
    name: 'Chùa Vĩnh Nghiêm',
    address: 'TP. Hồ Chí Minh',
    description:
        'Chùa Vĩnh Nghiêm là một trong những ngôi chùa nổi tiếng '
        'tại Thành phố Hồ Chí Minh.',
    history:
        'Chùa mang nét kiến trúc Phật giáo truyền thống kết hợp '
        'với quy mô xây dựng hiện đại.',
    image: 'assets/images/chua_vinh_nghiem.jpg',
  ),
];

Temple? findTempleById(String id) {
  try {
    return demoTemples.firstWhere(
      (temple) => temple.id == id,
    );
  } catch (_) {
    return null;
  }
}