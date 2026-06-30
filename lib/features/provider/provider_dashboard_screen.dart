import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../viewmodels/provider_viewmodel.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  final _db = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _isOnline = true;

  // ── Services subcollection ref ─────────────────────────────────────
  late final CollectionReference _servicesRef;

  // ── Streams — created ONCE, not on every build(), so StreamBuilder
  // doesn't reset to a loading state on unrelated rebuilds (e.g. the
  // online/offline toggle calling setState). ────────────────────────
  late final Stream<int> _activeBookingsCount;
  late final Stream<QuerySnapshot> _servicesStream;

  @override
  void initState() {
    super.initState();
    _servicesRef =
        _db.collection('providers').doc(_uid).collection('services');

    _activeBookingsCount = _db
        .collection('bookings')
        .where('providerId', isEqualTo: _uid)
        .where('status', whereIn: ['pending', 'confirmed'])
        .snapshots()
        .map((s) => s.docs.length);

    _servicesStream =
        _servicesRef.orderBy('createdAt', descending: false).snapshots();
  }

  // ── Add / Edit service dialog ──────────────────────────────────────
  void _showServiceDialog({Map<String, dynamic>? existing, String? docId}) {
    final nameCtrl =
        TextEditingController(text: existing?['name'] ?? '');
    final descCtrl =
        TextEditingController(text: existing?['description'] ?? '');
    final priceCtrl = TextEditingController(
        text: existing != null
            ? (existing['price'] as num).toStringAsFixed(0)
            : '');
    final durationCtrl =
        TextEditingController(text: existing?['duration'] ?? '');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  existing == null ? 'Add New Service' : 'Edit Service',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 20),
                _field(nameCtrl, 'Service Name',
                    hint: 'e.g. Full House Wiring'),
                const SizedBox(height: 14),
                _field(descCtrl, 'Description',
                    hint: 'What does this service include?', maxLines: 2),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _field(priceCtrl, 'Price (Rs.)',
                          hint: '500',
                          keyboardType: TextInputType.number,
                          validator: (v) => (v == null ||
                                  double.tryParse(v) == null)
                              ? 'Enter a valid price'
                              : null),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _field(durationCtrl, 'Duration',
                          hint: 'e.g. 2-3 hours'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: AppTheme.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final data = {
                        'name': nameCtrl.text.trim(),
                        'description': descCtrl.text.trim(),
                        'price': double.parse(priceCtrl.text.trim()),
                        'duration': durationCtrl.text.trim(),
                        'isAvailable': existing?['isAvailable'] ?? true,
                        'updatedAt': FieldValue.serverTimestamp(),
                      };
                      if (docId == null) {
                        data['createdAt'] = FieldValue.serverTimestamp();
                        try {
                          await _servicesRef.add(data);
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text('Failed to publish: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      } else {
                        try {
                          await _servicesRef.doc(docId).update(data);
                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: Text(
                      existing == null ? 'Publish Service' : 'Save Changes',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    String hint = '',
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator ??
          (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppTheme.greyText, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.lightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.lightGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primaryOrange, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  void _deleteService(String docId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Remove "$name" from your listed services?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              try {
                await _servicesRef.doc(docId).delete();
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerVM = context.watch<ProviderViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ───────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome back,',
                          style: TextStyle(
                              color: AppTheme.greyText, fontSize: 14)),
                      Text(
                        providerVM.provider?.businessName ??
                            'Professional Mode',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkText,
                        ),
                      ),
                    ],
                  ),
                  // Online / Offline toggle
                  GestureDetector(
                    onTap: () async {
                      setState(() => _isOnline = !_isOnline);
                      await _db
                          .collection('providers')
                          .doc(_uid)
                          .update({'isActive': _isOnline});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _isOnline
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: _isOnline
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Switch.adaptive(
                            value: _isOnline,
                            activeColor: Colors.green,
                            onChanged: (v) async {
                              setState(() => _isOnline = v);
                              await _db
                                  .collection('providers')
                                  .doc(_uid)
                                  .update({'isActive': v});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Stats card ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('Total Earnings',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      'Rs. ${(providerVM.earningSummary['totalEarnings'] ?? 0.0).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('Jobs Done',
                            '${providerVM.provider?.totalJobs ?? 0}'),
                        Container(
                            width: 1,
                            height: 30,
                            color: Colors.white24),
                        _stat('Rating',
                            '${(providerVM.provider?.rating ?? 0.0).toStringAsFixed(1)} ⭐'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Active requests summary ──────────────────────────
              StreamBuilder<int>(
                stream: _activeBookingsCount,
                builder: (context, snap) {
                  final count = snap.data ?? 0;
                  return count == 0
                      ? const SizedBox.shrink()
                      : Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.lightOrange,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppTheme.primaryOrange
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active_rounded,
                                  color: AppTheme.primaryOrange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'You have $count active booking request${count == 1 ? '' : 's'}. Check your Jobs tab.',
                                  style: const TextStyle(
                                    color: AppTheme.darkText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                },
              ),

              const SizedBox(height: 28),

              // ── My Services ──────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkText,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showServiceDialog(),
                    icon: const Icon(Icons.add_circle_outline_rounded,
                        size: 18, color: AppTheme.primaryOrange),
                    label: const Text('Add',
                        style: TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              const Text(
                'Customers see these services when they view your profile.',
                style:
                    TextStyle(fontSize: 12, color: AppTheme.greyText),
              ),

              const SizedBox(height: 16),

              // ── Services list ────────────────────────────────────
              StreamBuilder<QuerySnapshot>(
                stream: _servicesStream,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primaryOrange));
                  }

                  final docs = snap.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.lightGrey, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.handyman_rounded,
                              size: 48, color: AppTheme.greyText),
                          const SizedBox(height: 12),
                          const Text(
                            'No services published yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Add services so customers can find and book you.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13, color: AppTheme.greyText),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showServiceDialog(),
                            icon: const Icon(Icons.add_rounded,
                                color: AppTheme.white),
                            label: const Text('Add Your First Service',
                                style:
                                    TextStyle(color: AppTheme.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryOrange,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: docs.map((doc) {
                      final data =
                          doc.data() as Map<String, dynamic>;
                      final isAvailable =
                          data['isAvailable'] as bool? ?? true;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isAvailable
                                ? AppTheme.primaryOrange
                                    .withValues(alpha: 0.3)
                                : AppTheme.lightGrey,
                          ),
                          boxShadow: const [
                            BoxShadow(
                                color: AppTheme.cardShadow,
                                blurRadius: 8,
                                offset: Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    data['name'] as String? ??
                                        'Service',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.darkText,
                                    ),
                                  ),
                                ),
                                // Available toggle
                                Row(
                                  children: [
                                    Text(
                                      isAvailable
                                          ? 'Available'
                                          : 'Hidden',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isAvailable
                                            ? Colors.green
                                            : AppTheme.greyText,
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: isAvailable,
                                      activeColor: Colors.green,
                                      onChanged: (v) =>
                                          _servicesRef
                                              .doc(doc.id)
                                              .update(
                                                  {'isAvailable': v}),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if ((data['description'] as String? ?? '')
                                .isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                data['description'] as String,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.greyText),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightOrange,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Rs. ${(data['price'] as num).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryOrange,
                                    ),
                                  ),
                                ),
                                if ((data['duration'] as String? ?? '')
                                    .isNotEmpty) ...[
                                  const SizedBox(width: 10),
                                  const Icon(Icons.timer_outlined,
                                      size: 14,
                                      color: AppTheme.greyText),
                                  const SizedBox(width: 4),
                                  Text(
                                    data['duration'] as String,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.greyText),
                                  ),
                                ],
                                const Spacer(),
                                // Edit
                                IconButton(
                                  onPressed: () => _showServiceDialog(
                                    existing: data,
                                    docId: doc.id,
                                  ),
                                  icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: AppTheme.greyText),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 12),
                                // Delete
                                IconButton(
                                  onPressed: () => _deleteService(
                                      doc.id,
                                      data['name'] as String? ??
                                          'Service'),
                                  icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Colors.red),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        Text(label,
            style: const TextStyle(
                color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}
