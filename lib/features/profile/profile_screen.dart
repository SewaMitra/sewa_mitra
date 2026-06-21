import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../provider/join_provider_screen.dart';
import '../provider/earning_screen.dart';
import '../wallet/transaction_screen.dart';
import '../admin/user_management_screen.dart';
import '../provider/provider_management_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Loading...';
  String _email = '';
  String? _photoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getUserProfile();
    if (mounted) {
      setState(() {
        if (profile != null) {
          _name = profile['fullName'] ?? 'User';
          _email = profile['email'] ?? '';
          _photoUrl = profile['photoUrl'];
        } else {
          final user = AuthService.currentUser;
          _name = user?.displayName ?? 'User';
          _email = user?.email ?? '';
          _photoUrl = user?.photoURL;
        }
        _isLoading = false;
      });
    }
  }

  void _navigateTo(Widget page) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (result != null) {
      setState(() {
        _name = result['name'] ?? _name;
        _email = result['email'] ?? _email;
        _photoUrl = result['photoUrl'] ?? _photoUrl;
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
            onPressed: () async {
              // 1. Close the dialog first
              Navigator.of(context, rootNavigator: true).pop();
              
              // 2. Sign out (this triggers AuthWrapper to show LoginScreen)
              await AuthService.signOut();
              
              // 3. Show a snackbar on the LoginScreen (optional, might need a different context)
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully')),
                );
              }
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: _photoUrl != null && _photoUrl!.isNotEmpty
                            ? Image.network(_photoUrl!, fit: BoxFit.cover)
                            : const Icon(Icons.person_rounded,
                                color: AppTheme.primaryOrange, size: 50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_name,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkText)),
                    const SizedBox(height: 4),
                    Text(_email,
                        style: const TextStyle(
                            fontSize: 14, color: AppTheme.greyText)),
                    const SizedBox(height: 28),

                    // ── Menu items ──────────────────────────────────────────────
                    _ProfileTile(
                      icon: Icons.edit_rounded,
                      label: 'Edit Profile',
                      onTap: () => _navigateTo(
                        EditProfileScreen(
                            name: _name, email: _email, photoUrl: _photoUrl),
                      ),
                    ),
              _ProfileTile(
                icon: Icons.work_rounded,
                label: 'Join as Provider',
                onTap: () => _navigateTo(const JoinProviderScreen()),
              ),
              _ProfileTile(
                icon: Icons.location_on_rounded,
                label: 'My Addresses',
                onTap: () => _navigateTo(const MyAddressesScreen()),
              ),
              _ProfileTile(
                icon: Icons.history_rounded,
                label: 'Transactions',
                onTap: () => _navigateTo(const TransactionScreen()),
              ),
              _ProfileTile(
                icon: Icons.analytics_outlined,
                label: 'My Earnings',
                onTap: () => _navigateTo(const EarningScreen()),
              ),
              const Divider(height: 32, thickness: 1, indent: 20, endIndent: 20),
              const Padding(
                padding: EdgeInsets.only(left: 24, bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Admin Tools',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.greyText)),
                ),
              ),
              _ProfileTile(
                icon: Icons.group_outlined,
                label: 'User Management',
                onTap: () => _navigateTo(const UserManagementScreen()),
              ),
              _ProfileTile(
                icon: Icons.engineering_outlined,
                label: 'Provider Management',
                onTap: () => _navigateTo(const ProviderManagementScreen()),
              ),
              const SizedBox(height: 10),
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

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String? photoUrl;
  const EditProfileScreen(
      {super.key, required this.name, required this.email, this.photoUrl});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  String? _currentPhotoUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _emailCtrl = TextEditingController(text: widget.email);
    _phoneCtrl = TextEditingController(text: '+977 9800000000');
    _currentPhotoUrl = widget.photoUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      String? newPhotoUrl = _currentPhotoUrl;

      if (_imageFile != null) {
        newPhotoUrl = await AuthService.uploadProfileImage(_imageFile!);
      }

      final result = await AuthService.updateProfile(
        fullName: _nameCtrl.text.trim(),
        photoUrl: newPhotoUrl,
      );

      setState(() => _isSaving = false);

      if (result.success) {
        Navigator.pop(context, {
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'photoUrl': newPhotoUrl,
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage ?? 'Update failed')),
        );
      }
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
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                          color: AppTheme.lightOrange, shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : (_currentPhotoUrl != null &&
                                    _currentPhotoUrl!.isNotEmpty
                                ? Image.network(_currentPhotoUrl!,
                                    fit: BoxFit.cover)
                                : const Icon(Icons.person_rounded,
                                    color: AppTheme.primaryOrange, size: 50)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: AppTheme.primaryOrange,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildField('Full Name', _nameCtrl,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Name is required' : null),
            const SizedBox(height: 14),
            _buildField('Email', _emailCtrl,
                enabled: false,
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
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {TextInputType? keyboardType,
      String? Function(String?)? validator,
      bool enabled = true}) {
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
          enabled: enabled,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppTheme.white : Colors.grey.shade200,
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
