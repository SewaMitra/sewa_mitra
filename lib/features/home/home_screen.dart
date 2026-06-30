import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../services/provider_service.dart';
import '../../shared/models/backend_models.dart';
import '../../shared/widgets/category_card.dart';
import '../../shared/widgets/provider_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProviderService _providerService = ProviderService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const String _workerUrl =
      'https://cdn3d.iconscout.com/3d/premium/thumb/construction-worker-3d-illustration-download-in-png-blend-fbx-gltf-file-formats--helmet-builder-architecture-pack-people-illustrations-4863042.png';

  // category name -> icon URL (display only, tapping filters real providers by category)
  static const Map<String, String> _categoryImages = {
    'Electrical':
        'https://cdn-icons-png.flaticon.com/512/3114/3114829.png',
    'Plumbing':
        'https://cdn-icons-png.flaticon.com/512/2933/2933245.png',
    'Cleaning':
        'https://cdn-icons-png.flaticon.com/512/3079/3079165.png',
    'Carpentry':
        'https://cdn-icons-png.flaticon.com/512/2969/2969648.png',
    'AC Repair':
        'https://cdn-icons-png.flaticon.com/512/2516/2516697.png',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToCategory(String category) {
    context.push('/services', extra: {'category': category});
  }

  void _goToProvider(ProviderModel provider) {
    context.push('/service/${provider.id}');
  }

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
              // ── Location + notifications ─────────────────────────
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
                      onTap: () => context.push('/notifications'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.cardShadow,
                              blurRadius: 8,
                              offset: Offset(0, 2),
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

              // ── Search + filter ───────────────────────────────────
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
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.cardShadow,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onSubmitted: (v) {
                            context.push('/services', extra: {
                              'searchQuery': v.trim(),
                            });
                          },
                          decoration: const InputDecoration(
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
                      onTap: () => context.push('/filter'),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryOrange
                                  .withValues(alpha: 0.3),
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

              // ── Banner ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 165,
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.cardShadow,
                        blurRadius: 12,
                        offset: Offset(0, 4),
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
                            color:
                                AppTheme.primaryOrange.withValues(alpha: 0.07),
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
                            color:
                                AppTheme.primaryOrange.withValues(alpha: 0.05),
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
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightOrange,
                                    borderRadius: BorderRadius.circular(14),
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

              // ── Categories header ──────────────────────────────────
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
                      onPressed: () => context.push('/services'),
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

              // ── Category grid — taps filter real providers ────────
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
                        onTap: () => _goToCategory(e.key),
                      ),
                    ),
                    CategoryCard(
                      name: 'More',
                      icon: _buildMoreIcon(),
                      onTap: () => context.push('/services'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Popular providers header ───────────────────────────
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
                      onPressed: () => context.push('/services'),
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

              // ── Real providers from Firestore ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<List<ProviderModel>>(
                  stream: _providerService.getAllProviders(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primaryOrange),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'Could not load providers: ${snapshot.error}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.greyText),
                        ),
                      );
                    }

                    final providers = snapshot.data ?? [];

                    if (providers.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.engineering_outlined,
                                size: 40, color: AppTheme.greyText),
                            SizedBox(height: 10),
                            Text(
                              'No providers yet',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.darkText,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Approved providers will show up here once they join.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.greyText),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show top 5 by rating on the home screen
                    final topProviders = providers.take(5).toList();

                    return Column(
                      children: topProviders
                          .map((p) => ProviderCard(
                                name: p.businessName,
                                rating: p.rating,
                                reviewCount: p.totalReviews,
                                startingPrice: p.basePrice,
                                currency: 'Rs.',
                                avatar: _buildProviderAvatar(p),
                                onTap: () => _goToProvider(p),
                              ))
                          .toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProviderAvatar(ProviderModel provider) {
    if (provider.profileImage != null && provider.profileImage!.isNotEmpty) {
      return Image.network(
        provider.profileImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _avatarInitials(provider),
      );
    }
    return _avatarInitials(provider);
  }

  Widget _avatarInitials(ProviderModel provider) {
    final initial = provider.businessName.isNotEmpty
        ? provider.businessName[0].toUpperCase()
        : '?';
    return Container(
      color: AppTheme.lightOrange,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AppTheme.primaryOrange,
            fontSize: 26,
            fontWeight: FontWeight.bold,
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
          Icons.handyman_rounded,
          color: AppTheme.primaryOrange,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildMoreIcon() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.lightOrange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.apps_rounded,
        color: AppTheme.primaryOrange,
        size: 28,
      ),
    );
  }
}
