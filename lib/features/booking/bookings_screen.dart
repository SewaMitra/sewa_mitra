import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../shared/models/models.dart';
import '../../viewmodels/user_viewmodel.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // ── Mock customer bookings ─────────────────────────────────────────
  static final List<Map<String, dynamic>> _customerBookings = [
    {
      'id': 'b1',
      'serviceName': 'Electrical Wiring',
      'providerName': 'Ramesh Shrestha',
      'providerAvatar':
          'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=200&h=200&fit=crop&crop=face',
      'date': 'Jul 2, 2026',
      'time': '10:00 AM',
      'address': 'Thamel, Kathmandu',
      'amount': 1500.0,
      'status': 'Confirmed',
      'category': 'Electrical',
    },
    {
      'id': 'b2',
      'serviceName': 'Pipe Repair',
      'providerName': 'Sanjay Tamang',
      'providerAvatar':
          'https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?w=200&h=200&fit=crop&crop=face',
      'date': 'Jun 28, 2026',
      'time': '2:00 PM',
      'address': 'Patan, Lalitpur',
      'amount': 800.0,
      'status': 'Completed',
      'category': 'Plumbing',
    },
    {
      'id': 'b3',
      'serviceName': 'Deep Home Cleaning',
      'providerName': 'Anita Gurung',
      'providerAvatar':
          'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=200&h=200&fit=crop&crop=face',
      'date': 'Jul 5, 2026',
      'time': '9:00 AM',
      'address': 'Bhaktapur',
      'amount': 2200.0,
      'status': 'Pending',
      'category': 'Cleaning',
    },
    {
      'id': 'b4',
      'serviceName': 'AC Service',
      'providerName': 'Bikash Karki',
      'providerAvatar':
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&h=200&fit=crop&crop=face',
      'date': 'Jun 20, 2026',
      'time': '11:00 AM',
      'address': 'Baneshwor, Kathmandu',
      'amount': 1200.0,
      'status': 'Cancelled',
      'category': 'AC Repair',
    },
  ];

  // ── Mock provider job requests ─────────────────────────────────────
  static final List<Map<String, dynamic>> _providerJobs = [
    {
      'id': 'j1',
      'customerName': 'Aarav Joshi',
      'customerAvatar':
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=200&h=200&fit=crop&crop=face',
      'serviceName': 'Electrical Wiring',
      'date': 'Jul 2, 2026',
      'time': '10:00 AM',
      'address': 'Thamel, Kathmandu',
      'amount': 1500.0,
      'status': 'New',
      'description': 'Full apartment rewiring, 2BHK',
    },
    {
      'id': 'j2',
      'customerName': 'Priya Maharjan',
      'customerAvatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop&crop=face',
      'serviceName': 'Socket Installation',
      'date': 'Jul 3, 2026',
      'time': '3:00 PM',
      'address': 'Lalitpur',
      'amount': 500.0,
      'status': 'Accepted',
      'description': 'Install 4 new power sockets in living room',
    },
    {
      'id': 'j3',
      'customerName': 'Suresh Bhandari',
      'customerAvatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop&crop=face',
      'serviceName': 'Fuse Box Repair',
      'date': 'Jun 25, 2026',
      'time': '1:00 PM',
      'address': 'Bhaktapur',
      'amount': 700.0,
      'status': 'Completed',
      'description': 'Main fuse box tripping frequently',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userVM = context.watch<UserViewModel>();
    final isProviderMode = userVM.activeMode == 'provider';

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.bgColor,
        elevation: 0,
        title: Text(
          isProviderMode ? 'My Jobs' : 'My Bookings',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.darkText,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryOrange,
          indicatorWeight: 3,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: AppTheme.greyText,
          labelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600),
          tabs: isProviderMode
              ? const [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                ]
              : const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
        ),
      ),
      body: isProviderMode
          ? _buildProviderView()
          : _buildCustomerView(),
    );
  }

  // ── CUSTOMER VIEW ──────────────────────────────────────────────────

  Widget _buildCustomerView() {
    final upcoming = _customerBookings
        .where((b) => b['status'] == 'Confirmed' || b['status'] == 'Pending')
        .toList();
    final past = _customerBookings
        .where((b) => b['status'] == 'Completed' || b['status'] == 'Cancelled')
        .toList();

    return TabBarView(
      controller: _tabController,
      children: [
        _bookingList(upcoming, emptyLabel: 'No upcoming bookings'),
        _bookingList(past, emptyLabel: 'No past bookings'),
      ],
    );
  }

  Widget _bookingList(List<Map<String, dynamic>> items,
      {required String emptyLabel}) {
    if (items.isEmpty) return _emptyState(emptyLabel);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: items.length,
      itemBuilder: (context, i) => _customerBookingCard(items[i]),
    );
  }

  Widget _customerBookingCard(Map<String, dynamic> b) {
    final status = b['status'] as String;
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Top row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    b['providerAvatar'] as String,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 54,
                      height: 54,
                      color: AppTheme.lightOrange,
                      child: const Icon(Icons.person,
                          color: AppTheme.primaryOrange),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b['serviceName'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        b['providerName'] as String,
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.greyText),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppTheme.lightGrey),

          // Details row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                _infoChip(Icons.calendar_today_rounded,
                    '${b['date']}  ${b['time']}'),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoChip(
                      Icons.location_on_rounded, b['address'] as String),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppTheme.lightGrey),

          // Amount + action
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rs. ${(b['amount'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                if (status == 'Completed')
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.star_border_rounded, size: 16),
                    label: const Text('Rate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryOrange,
                      side: const BorderSide(color: AppTheme.primaryOrange),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                if (status == 'Pending')
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                if (status == 'Confirmed')
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryOrange,
                      side: const BorderSide(color: AppTheme.primaryOrange),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PROVIDER VIEW ──────────────────────────────────────────────────

  Widget _buildProviderView() {
    final active = _providerJobs
        .where((j) => j['status'] == 'New' || j['status'] == 'Accepted')
        .toList();
    final completed =
        _providerJobs.where((j) => j['status'] == 'Completed').toList();

    return TabBarView(
      controller: _tabController,
      children: [
        _providerJobList(active, emptyLabel: 'No active job requests'),
        _providerJobList(completed, emptyLabel: 'No completed jobs yet'),
      ],
    );
  }

  Widget _providerJobList(List<Map<String, dynamic>> jobs,
      {required String emptyLabel}) {
    if (jobs.isEmpty) return _emptyState(emptyLabel);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: jobs.length,
      itemBuilder: (context, i) => _providerJobCard(jobs[i]),
    );
  }

  Widget _providerJobCard(Map<String, dynamic> j) {
    final status = j['status'] as String;
    final isNew = status == 'New';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(18),
        border: isNew
            ? Border.all(color: AppTheme.primaryOrange, width: 1.5)
            : null,
        boxShadow: const [
          BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 10,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          if (isNew)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppTheme.primaryOrange,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Text(
                'New Request',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    j['customerAvatar'] as String,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 54,
                      height: 54,
                      color: AppTheme.lightGrey,
                      child: const Icon(Icons.person, color: AppTheme.greyText),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        j['serviceName'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'By ${j['customerName']}',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.greyText),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Rs. ${(j['amount'] as double).toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                j['description'] as String,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.greyText),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              children: [
                _infoChip(Icons.calendar_today_rounded,
                    '${j['date']}  ${j['time']}'),
                const SizedBox(width: 8),
                Expanded(
                  child: _infoChip(Icons.location_on_rounded,
                      j['address'] as String),
                ),
              ],
            ),
          ),

          if (isNew)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Decline',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: AppTheme.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text('Accept',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── Shared helpers ─────────────────────────────────────────────────

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppTheme.greyText),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.lightOrange,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: AppTheme.primaryOrange, size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.darkText,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Nothing here yet',
            style: TextStyle(fontSize: 13, color: AppTheme.greyText),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Confirmed':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return AppTheme.greyText;
    }
  }
}
