class ServiceCategory {
  final String name;
  final String iconPath;
  final IconData? icon;

  const ServiceCategory({
    required this.name,
    this.iconPath = '',
    this.icon,
  });
}

class ServiceProvider {
  final String name;
  final double rating;
  final int reviewCount;
  final double startingPrice;
  final String currency;
  final String imagePath;
  final String specialty;

  const ServiceProvider({
    required this.name,
    required this.rating,
    required this.reviewCount,
    required this.startingPrice,
    required this.currency,
    required this.imagePath,
    required this.specialty,
  });
}
