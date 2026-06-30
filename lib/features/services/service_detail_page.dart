import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({super.key});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  final _db = FirebaseFirestore.instance;

  // providerId comes from the route: /service/:serviceId
  String get _providerId =>
      GoRouterState.of(context).pathParameters['serviceId'] ?? '';

  // Which service the customer selected (to pass to booking)
  String? _selectedServiceId;
  String? _selectedServiceName;
  double? _selectedServicePrice;

  // ── Cached future/streams — created ONCE in didChangeDependencies,
  // not on every build(). Without this, every setState() (e.g. tapping
  // a service card to select it) recreates the Future/Stream, which
  // resets FutureBuilder/StreamBuilder back to a loading state and
  // wipes the screen — the "flash then disappear" bug. ───────────────
  Future<Map<String, dynamic>?>? _providerFuture;
  Stream<List<Map<String, dynamic>>>? _servicesStream;
  Stream<List<Map<String, dynamic>>>? _reviewsStream;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _providerFuture = _fetchProvider();
      _servicesStream = _buildServicesStream();
      _reviewsStream = _buildReviewsStream();
    }
  }

  // ── Data fetchers ─────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _fetchProvider() async {
    final doc =
        await _db.collection('providers').doc(_providerId).get();
    return doc.exists ? {'id': doc.id, ...doc.data()!} : null;
  }

  Stream<List<Map<String, dynamic>>> _buildServicesStream() {
    return _db
        .collection('providers')
        .doc(_providerId)
        .collection('services')
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Stream<List<Map<String, dynamic>>> _buildReviewsStream() {
    return _db
        .collection('providers')
        .doc(_providerId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _providerFuture,
      builder: (context, provSnap) {
        if (provSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child: CircularProgressIndicator(
                    color: AppTheme.primaryOrange)),
          );
        }

        final provider = provSnap.data;

        if (provider == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Provider not found.')),
          );
        }

        final businessName =
            provider['businessName'] as String? ?? 'Provider';
        final category = provider['category'] as String? ?? '';
        final rating =
            (provider['rating'] as num?)?.toDouble() ?? 0.0;
        final totalReviews = provider['totalReviews'] as int? ?? 0;
        final isVerified = provider['isVerified'] as bool? ?? false;
        final description =
            provider['description'] as String? ?? '';
        final initials =
            businessName.isNotEmpty ? businessName[0].toUpperCase() : 'P';

        return Scaffold(
          backgroundColor: AppTheme.bgColor,
          body: CustomScrollView(
            slivers: [
              // ── App bar with provider header ───────────────────
              SliverAppBar(
                backgroundColor: const Color(0xFF1A1A2E),
                foregroundColor: Colors.white,
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: const Color(0xFF1A1A2E),
                    padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryOrange,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      businessName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isVerified)
                                    const Icon(Icons.verified_rounded,
                                        color: Colors.lightBlueAccent,
                                        size: 18),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category,
                                style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      color: AppTheme.starYellow,
                                      size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${rating.toStringAsFixed(1)} ($totalReviews reviews)',
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── About ──────────────────────────────────
                      if (description.isNotEmpty) ...[
                        const Text(
                          'About',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.greyText,
                              height: 1.5),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── Trust badge ────────────────────────────
                      if (isVerified)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.green.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Icon(Icons.verified_user_outlined,
                                  color: Colors.green.shade700,
                                  size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Identity verified  ·  Approved by Sewa Mitra',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Services ───────────────────────────────
                      const Text(
                        'Available Services',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap a service to select it for booking',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.greyText),
                      ),
                      const SizedBox(height: 14),

                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _servicesStream,
                        builder: (context, snap) {
                          if (snap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator(
                                    color: AppTheme.primaryOrange));
                          }

                          if (snap.hasError) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: Colors.red.shade200),
                              ),
                              child: Text(
                                'Error loading services:\n${snap.error}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade700),
                              ),
                            );
                          }

                          final services = snap.data ?? [];

                          if (services.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.white,
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'This provider hasn\'t published any services yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: AppTheme.greyText,
                                    fontSize: 13),
                              ),
                            );
                          }

                          return Column(
                            children: services.map((svc) {
                              final isSelected =
                                  _selectedServiceId == svc['id'];
                              return GestureDetector(
                                onTap: () => setState(() {
                                  _selectedServiceId = svc['id'];
                                  _selectedServiceName =
                                      svc['name'] as String?;
                                  _selectedServicePrice =
                                      (svc['price'] as num?)
                                          ?.toDouble();
                                }),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.only(
                                      bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.lightOrange
                                        : AppTheme.white,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primaryOrange
                                          : AppTheme.lightGrey,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: AppTheme.cardShadow,
                                          blurRadius: 6,
                                          offset: Offset(0, 2)),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              svc['name'] as String? ??
                                                  '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: AppTheme.darkText,
                                              ),
                                            ),
                                            if ((svc['description']
                                                        as String? ??
                                                    '')
                                                .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                svc['description']
                                                    as String,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme.greyText),
                                              ),
                                            ],
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  'Rs. ${(svc['price'] as num).toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    color: AppTheme
                                                        .primaryOrange,
                                                  ),
                                                ),
                                                if ((svc['duration']
                                                            as String? ??
                                                        '')
                                                    .isNotEmpty) ...[
                                                  const SizedBox(
                                                      width: 10),
                                                  const Icon(
                                                      Icons
                                                          .timer_outlined,
                                                      size: 13,
                                                      color: AppTheme
                                                          .greyText),
                                                  const SizedBox(
                                                      width: 3),
                                                  Text(
                                                    svc['duration']
                                                        as String,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppTheme
                                                            .greyText),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: const BoxDecoration(
                                            color: AppTheme.primaryOrange,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                              Icons.check_rounded,
                                              color: Colors.white,
                                              size: 16),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Reviews ────────────────────────────────
                      const Text(
                        'Recent Reviews',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 14),

                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _reviewsStream,
                        builder: (context, snap) {
                          final reviews = snap.data ?? [];
                          if (reviews.isEmpty) {
                            return const Text(
                              'No reviews yet. Be the first to book!',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.greyText),
                            );
                          }
                          return Column(
                            children: reviews
                                .map((r) => _reviewCard(r))
                                .toList(),
                          );
                        },
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Book button ──────────────────────────────────────────
          bottomNavigationBar: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: AppTheme.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedServiceName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedServiceName!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'Rs. ${_selectedServicePrice?.toStringAsFixed(0) ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryOrange,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _selectedServiceId == null
                        ? null
                        : () {
                            context.push(
                              '/book/$_providerId',
                              extra: {
                                'serviceId': _selectedServiceId,
                                'serviceName': _selectedServiceName,
                                'price': _selectedServicePrice,
                                'providerId': _providerId,
                                'providerName': businessName,
                              },
                            );
                          },
                    icon: const Icon(Icons.calendar_month_outlined,
                        color: Colors.white),
                    label: Text(
                      _selectedServiceId == null
                          ? 'Select a Service to Book'
                          : 'Book Now',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedServiceId == null
                          ? AppTheme.greyText
                          : AppTheme.primaryOrange,
                      disabledBackgroundColor: AppTheme.lightGrey,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reviewCard(Map<String, dynamic> r) {
    final rating = (r['rating'] as num?)?.toInt() ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                r['customerName'] as String? ?? 'Customer',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkText,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppTheme.starYellow,
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            r['comment'] as String? ?? '',
            style: const TextStyle(
                fontSize: 13, color: AppTheme.greyText, height: 1.4),
          ),
        ],
      ),
    );
  }
}
