import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ════════════════════════════════════════════════════════════════════════════
//  WALLET SCREEN (unchanged)
// ════════════════════════════════════════════════════════════════════════════
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text(
          'Wallet',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.darkText),
        ),
        backgroundColor: AppTheme.bgColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryOrange, Color(0xFFEA580C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Available Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 8),
                  Text('Rs. 2,450',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _WalletAction(icon: Icons.add_circle_rounded, label: 'Add Money'),
                const SizedBox(width: 12),
                _WalletAction(icon: Icons.send_rounded, label: 'Send Money'),
                const SizedBox(width: 12),
                _WalletAction(icon: Icons.history_rounded, label: 'History'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _WalletAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryOrange, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.darkText)),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  NOTIFICATIONS SCREEN (unchanged)
// ════════════════════════════════════════════════════════════════════════════
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText)),
        backgroundColor: AppTheme.bgColor,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        itemBuilder: (context, index) {
          final titles = ['Booking Confirmed', 'Service Completed', 'Special Offer'];
          final subtitles = [
            'Electric Pro will arrive at 10:00 AM',
            'Rate your recent cleaning service',
            '20% off on AC Repair this weekend'
          ];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.lightOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_rounded,
                      color: AppTheme.primaryOrange, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titles[index],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.darkText)),
                      const SizedBox(height: 4),
                      Text(subtitles[index],
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.greyText)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PROFILE SCREEN — fully working
// ════════════════════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Ram Shrestha';
  String _email = 'ram@example.com';

  void _navigateTo(Widget page) async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (result != null) {
      setState(() {
        _name = result['name'] ?? _name;
        _email = result['email'] ?? _email;
      });
    }
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppTheme.lightOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: AppTheme.primaryOrange, size: 50),
              ),
              const SizedBox(height: 12),
              Text(_name,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkText)),
              const SizedBox(height: 4),
              Text(_email,
                  style: const TextStyle(fontSize: 14, color: AppTheme.greyText)),
              const SizedBox(height: 28),

              // ── Menu items ──────────────────────────────────────────────
              _ProfileTile(
                icon: Icons.edit_rounded,
                label: 'Edit Profile',
                onTap: () => _navigateTo(
                  EditProfileScreen(name: _name, email: _email),
                ),
              ),
              _ProfileTile(
                icon: Icons.location_on_rounded,
                label: 'My Addresses',
                onTap: () => _navigateTo(const MyAddressesScreen()),
              ),
              _ProfileTile(
                icon: Icons.payment_rounded,
                label: 'Payment Methods',
                onTap: () => _navigateTo(const PaymentMethodsScreen()),
              ),
              _ProfileTile(
                icon: Icons.settings_rounded,
                label: 'Settings',
                onTap: () => _navigateTo(const SettingsScreen()),
              ),
              _ProfileTile(
                icon: Icons.help_rounded,
                label: 'Help & Support',
                onTap: () => _navigateTo(const HelpSupportScreen()),
              ),
              _ProfileTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                onTap: _confirmLogout,
                isDestructive: true,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable tile matching your existing style ───────────────────────────────
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isDestructive ? Colors.red : AppTheme.primaryOrange),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : AppTheme.darkText)),
        trailing:
            const Icon(Icons.chevron_right_rounded, color: AppTheme.greyText),
        onTap: onTap,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  EDIT PROFILE SCREEN
// ════════════════════════════════════════════════════════════════════════════
class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  const EditProfileScreen({super.key, required this.name, required this.email});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _emailCtrl = TextEditingController(text: widget.email);
    _phoneCtrl = TextEditingController(text: '+977 9800000000');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar('Edit Profile'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                        color: AppTheme.lightOrange, shape: BoxShape.circle),
                    child: const Icon(Icons.person_rounded,
                        color: AppTheme.primaryOrange, size: 50),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                          color: AppTheme.primaryOrange, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildField('Full Name', _nameCtrl,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Name is required' : null),
            const SizedBox(height: 14),
            _buildField('Email', _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                }),
            const SizedBox(height: 14),
            _buildField('Phone', _phoneCtrl,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Changes',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                color: AppTheme.greyText,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  MY ADDRESSES SCREEN
// ════════════════════════════════════════════════════════════════════════════
class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final List<Map<String, String>> _addresses = [
    {'label': 'Home', 'address': 'Baneshwor, Kathmandu, Nepal'},
    {'label': 'Work', 'address': 'Durbarmarg, Kathmandu, Nepal'},
  ];

  void _addAddress() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Address'),
        content: TextField(
            controller: ctrl,
            decoration:
                const InputDecoration(hintText: 'Enter address')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                setState(() => _addresses
                    .add({'label': 'Other', 'address': ctrl.text}));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar('My Addresses'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryOrange,
        onPressed: _addAddress,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _addresses.length,
        itemBuilder: (_, i) {
          final a = _addresses[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: AppTheme.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: AppTheme.lightOrange, shape: BoxShape.circle),
                child: const Icon(Icons.location_on,
                    color: AppTheme.primaryOrange),
              ),
              title: Text(a['label']!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(a['address']!),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => setState(() => _addresses.removeAt(i)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PAYMENT METHODS SCREEN
// ════════════════════════════════════════════════════════════════════════════
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _cards = [
    {'name': 'Visa', 'last4': '4242', 'icon': Icons.credit_card},
    {'name': 'Mastercard', 'last4': '5555', 'icon': Icons.credit_card_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar('Payment Methods'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ..._cards.asMap().entries.map((e) {
            final card = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: AppTheme.lightOrange, shape: BoxShape.circle),
                  child: Icon(card['icon'] as IconData,
                      color: AppTheme.primaryOrange),
                ),
                title: Text(card['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('•••• •••• •••• ${card['last4']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () =>
                      setState(() => _cards.removeAt(e.key)),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Add card feature coming soon'))),
            icon: const Icon(Icons.add, color: AppTheme.primaryOrange),
            label: const Text('Add New Card',
                style: TextStyle(color: AppTheme.primaryOrange)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.primaryOrange),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SETTINGS SCREEN
// ════════════════════════════════════════════════════════════════════════════
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _emailUpdates = false;
  bool _darkMode = false;
  bool _locationAccess = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar('Settings'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionLabel('Notifications'),
          _switchTile('Push Notifications', _notifications,
              (v) => setState(() => _notifications = v)),
          _switchTile('Email Updates', _emailUpdates,
              (v) => setState(() => _emailUpdates = v)),
          const SizedBox(height: 16),
          _sectionLabel('Preferences'),
          _switchTile('Dark Mode', _darkMode,
              (v) => setState(() => _darkMode = v)),
          _switchTile('Location Access', _locationAccess,
              (v) => setState(() => _locationAccess = v)),
          const SizedBox(height: 16),
          _sectionLabel('Account'),
          _actionTile('Change Password', Icons.lock_outline, () {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')));
          }),
          _actionTile('Delete Account', Icons.delete_forever_outlined,
              () {}, destructive: true),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                color: AppTheme.greyText,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
      );

  Widget _switchTile(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: SwitchListTile(
        title: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: AppTheme.darkText)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _actionTile(String label, IconData icon, VoidCallback onTap,
      {bool destructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: AppTheme.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Icon(icon,
            color: destructive ? Colors.red : AppTheme.primaryOrange),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: destructive ? Colors.red : AppTheme.darkText)),
        trailing: const Icon(Icons.chevron_right_rounded,
            color: AppTheme.greyText),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  HELP & SUPPORT SCREEN
// ════════════════════════════════════════════════════════════════════════════
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    {
      'q': 'How do I book a service?',
      'a':
          'Go to Home, browse services, select one, choose a time slot, and confirm your booking.'
    },
    {
      'q': 'How do I cancel a booking?',
      'a':
          'Go to Bookings tab, find your booking and tap "Cancel". Cancellations are free up to 2 hours before.'
    },
    {
      'q': 'How do I add a payment method?',
      'a':
          'Go to Profile → Payment Methods → Add New Card and enter your card details.'
    },
    {
      'q': 'How do I change my address?',
      'a':
          'Go to Profile → My Addresses to add, edit or delete addresses.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar('Help & Support'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Live chat banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Icon(Icons.support_agent, color: Colors.white, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chat with Us',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      SizedBox(height: 4),
                      Text('We typically reply within minutes',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('FAQs',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkText)),
          const SizedBox(height: 12),
          ..._faqs.map(
            (faq) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: ExpansionTile(
                title: Text(faq['q']!,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.darkText)),
                childrenPadding:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                iconColor: AppTheme.primaryOrange,
                collapsedIconColor: AppTheme.greyText,
                children: [
                  Text(faq['a']!,
                      style: const TextStyle(
                          color: AppTheme.greyText, fontSize: 13))
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Email: support@example.com'))),
            icon: const Icon(Icons.email_outlined,
                color: AppTheme.primaryOrange),
            label: const Text('Email Support',
                style: TextStyle(color: AppTheme.primaryOrange)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.primaryOrange),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SHARED APP BAR HELPER
// ════════════════════════════════════════════════════════════════════════════
AppBar _buildAppBar(String title) => AppBar(
      backgroundColor: AppTheme.bgColor,
      elevation: 0,
      centerTitle: true,
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppTheme.darkText)),
      iconTheme: const IconThemeData(color: AppTheme.darkText),
    );
