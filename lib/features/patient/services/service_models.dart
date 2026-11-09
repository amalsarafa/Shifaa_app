class ServiceItem {
  final String title;
  final String description;
  final String price;
  final String duration;
  final String image;

  final double rating;
  final int reviewsCount;
  final String longDescription;
  final String availability;
  final List<CareProvider> providers;

  const ServiceItem({
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.image,
    this.rating = 4.8,
    this.reviewsCount = 100,
    this.longDescription = '',
    this.availability = 'يومياً',
    this.providers = const [],
  });
}

class CareProvider {
  final String name;
  final String role;
  final double rating;
  final int yearsExp;
  final String image;
  final String phone;

  final int reviewsCount;
  final int visitsDone;
  final String about;
  final bool isVerified;
  final List<ProviderReview> reviews;

  const CareProvider({
    required this.name,
    required this.role,
    required this.rating,
    required this.yearsExp,
    required this.image,
    this.phone = '',
    this.reviewsCount = 0,
    this.visitsDone = 0,
    this.about = '',
    this.isVerified = true,
    this.reviews = const [],
  });
}

class ProviderReview {
  final String name;
  final String timeAgo;
  final double rating;
  final String comment;

  const ProviderReview({
    required this.name,
    required this.timeAgo,
    required this.rating,
    required this.comment,
  });
}

class ServiceCategory {
  final String title;
  final String subtitle;
  final List<ServiceItem> services;

  const ServiceCategory({
    required this.title,
    required this.subtitle,
    required this.services,
  });
}
