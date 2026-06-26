import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../shared/widgets/category_card.dart';
import '../../shared/widgets/provider_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String _workerUrl =
      'https://cdn3d.iconscout.com/3d/premium/thumb/construction-worker-3d-illustration-download-in-png-blend-fbx-gltf-file-formats--helmet-builder-architecture-pack-people-illustrations-4863042.png';

  static const Map<String, String> _categoryImages = {
    'Electricity':
    'https://cdn-icons-png.flaticon.com/512/3114/3114829.png',
    'Plumber':
    'https://cdn-icons-png.flaticon.com/512/2933/2933245.png',
    'Cleaning':
    'https://cdn-icons-png.flaticon.com/512/3079/3079165.png',
    'Laundry':
    'https://cdn-icons-png.flaticon.com/512/2969/2969648.png',
    'AC Repair':
    'https://cdn-icons-png.flaticon.com/512/2516/2516697.png',
  };

  static const List<String> _providerAvatars = [
    'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=200&h=200&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?w=200&h=200&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&h=200&fit=crop&crop=face',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: AppTheme.primaryOrange, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Kathmandu, Nepal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkText,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppTheme.darkText, size: 20),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push('/notifications');
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.cardShadow,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: AppTheme.darkText, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.cardShadow,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Search for services...',
                            hintStyle: TextStyle(
                              color: AppTheme.greyText,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: AppTheme.primaryOrange, size: 22),
                            border: InputBorder.none,
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        context.push('/filter');
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.tune_rounded,
                            color: AppTheme.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 165,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      Positioned(
                        right: -15,
                        top: -15,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.07),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 55,
                        bottom: -30,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 18, 10, 18),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Reliable Services\nRight at Your Doorstep',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.darkText,
                                      height: 1.35,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Book trusted professionals\nin just a few taps.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.greyText,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 118,
                              height: 145,
                              child: Image.network(
                                _workerUrl,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.primaryOrange,
                                      strokeWidth: 2,
                                      value: loadingProgress
                                          .expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          loadingProgress
                                              .expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.lightOrange,
                                        borderRadius:
                                        BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.engineering_rounded,
                                        color: AppTheme.primaryOrange,
                                        size: 52,
                                      ),
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    ..._categoryImages.entries.map(
                          (e) => CategoryCard(
                        name: e.key,
                        icon: _buildNetworkCategoryIcon(e.value),
                        onTap: () {
                          context.push('/service/1');
                        },
                      ),
                    ),
                    CategoryCard(
                      name: 'More',
                      icon: _buildMoreIcon(),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('More categories coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Providers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkText,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ProviderCard(
                      name: 'Electric Pro',
                      rating: 4.8,
                      reviewCount: 120,
                      startingPrice: 500,
                      currency: 'Rs.',
                      avatar: _buildNetworkAvatar(
                        _providerAvatars[0],
                        AppTheme.primaryOrange,
                      ),
                      onTap: () {
                        context.push('/service/1');
                      },
                    ),
                    ProviderCard(
                      name: 'Clean Masters',
                      rating: 4.6,
                      reviewCount: 98,
                      startingPrice: 800,
                      currency: 'Rs.',
                      avatar: _buildNetworkAvatar(
                        _providerAvatars[1],
                        const Color(0xFF8B5CF6),
                      ),
                      onTap: () {
                        context.push('/service/1');
                      },
                    ),
                    ProviderCard(
                      name: 'PlumbFix Nepal',
                      rating: 4.7,
                      reviewCount: 75,
                      startingPrice: 600,
                      currency: 'Rs.',
                      avatar: _buildNetworkAvatar(
                        _providerAvatars[2],
                        const Color(0xFF06B6D4),
                      ),
                      onTap: () {
                        context.push('/service/1');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkCategoryIcon(String url) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.primaryOrange,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.home_repair_service_rounded,
          color: AppTheme.primaryOrange,
          size: 32,
        ),
      ),
    );
  }

  Widget _buildNetworkAvatar(String url, Color fallbackColor) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: fallbackColor.withOpacity(0.1),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fallbackColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: fallbackColor.withOpacity(0.1),
        child: Icon(Icons.person_rounded, color: fallbackColor, size: 36),
      ),
    );
  }

  Widget _buildMoreIcon() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
                (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppTheme.primaryOrange,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
