// lib/screens/other_screens.dart
//
// All screens wired to Firebase.
// Changes from the original:
//   • ProfileScreen  — loads real user from Firestore on init
//   • EditProfileScreen — saves name/email/phone + uploads photo to Storage
//   • MyAddressesScreen — real-time Firestore stream, add/delete persisted
//   • SettingsScreen — every toggle saves to Firestore immediately
//   • Logout / Delete Account — calls AuthService

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

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
        title: const Text('Wallet',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.darkText)),
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
            BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryOrange, size: 28),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.darkText)),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.darkText)),
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
              boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: AppTheme.lightOrange, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.notifications_rounded, color: AppTheme.primaryOrange, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titles[index],
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.darkText)),
                      const SizedBox(height: 4),
                      Text(subtitles[index],
                          style: const TextStyle(fontSize: 12, color: AppTheme.greyText)),
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
//  PROFILE SCREEN — Firebase connected
// ════════════════════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firebase = FirebaseService();
  final _auth = AuthService();

  UserModel? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      // Wait for Firebase Auth to restore the session before reading currentUser.
      // Reading currentUser synchronously on first launch can return null even
      // when the user IS signed in, which causes the Firestore permission-denied error.
      String? uid = _auth.currentUser?.uid;
      if (uid == null) {
        // Auth session not yet restored — wait for the first emission.
        uid = await _auth.authStateChanges
            .first
            .then((user) => user?.uid);
      }
      if (uid == null) {
        setState(() { _loading = false; _error = 'Not logged in'; });
        return;
      }
      final user = await _firebase.getUser(uid);
      setState(() { _user = user; _loading = false; });
    } catch (e) {
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _navigateTo(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    // Reload after returning from any sub-screen
    _loadUser();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _auth.signOut();
              // _AuthGate in main.dart listens to authStateChanges and will
              // automatically redirect to LoginScreen — no manual navigation needed.
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.bgColor,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppTheme.bgColor,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadUser, child: const Text('Retry')),
          ]),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Avatar
              GestureDetector(
                onTap: () => _navigateTo(EditProfileScreen(user: _user!)),
                child: _UserAvatar(user: _user!, radius: 45),
              ),
              const SizedBox(height: 12),
              Text(_user?.name ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.darkText)),
              const SizedBox(height: 4),
              Text(_user?.email ?? '',
                  style: const TextStyle(fontSize: 14, color: AppTheme.greyText)),
              const SizedBox(height: 28),

              _ProfileTile(
                icon: Icons.edit_rounded,
                label: 'Edit Profile',
                onTap: () => _navigateTo(EditProfileScreen(user: _user!)),
              ),
              _ProfileTile(
                icon: Icons.location_on_rounded,
                label: 'My Addresses',
                onTap: () => _navigateTo(MyAddressesScreen(uid: _user!.uid)),
              ),
              _ProfileTile(
                icon: Icons.payment_rounded,
                label: 'Payment Methods',
                onTap: () => _navigateTo(const PaymentMethodsScreen()),
              ),
              _ProfileTile(
                icon: Icons.settings_rounded,
                label: 'Settings',
                onTap: () => _navigateTo(SettingsScreen(user: _user!)),
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
        boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : AppTheme.primaryOrange),
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : AppTheme.darkText)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.greyText),
        onTap: onTap,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  EDIT PROFILE SCREEN — saves to Firebase
// ════════════════════════════════════════════════════════════════════════════
class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  final _formKey = GlobalKey<FormState>();
  final _firebase = FirebaseService();
  final _picker = ImagePicker();

  /// Existing Base64 data URI (or legacy network URL) from Firestore.
  String? _existingPhoto;
  /// Newly picked local file — will be encoded to Base64 on save.
  File? _newImageFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _emailCtrl = TextEditingController(text: widget.user.email);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
    // Prefer Base64 over legacy network URL
    _existingPhoto = widget.user.photoBase64 ?? widget.user.photoUrl;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    final picked = await _picker.pickImage(
        source: source, imageQuality: 70, maxWidth: 400);
    if (picked != null) setState(() => _newImageFile = File(picked.path));
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const Text('Change Profile Photo',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppTheme.lightOrange,
                    child: Icon(Icons.camera_alt, color: AppTheme.primaryOrange)),
                title: const Text('Take Photo'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: AppTheme.lightOrange,
                    child: Icon(Icons.photo_library, color: AppTheme.primaryOrange)),
                title: const Text('Choose from Gallery'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              if (_newImageFile != null || _existingPhoto != null)
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEB),
                      child: Icon(Icons.delete_outline, color: Colors.red)),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() { _newImageFile = null; _existingPhoto = null; });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final uid = widget.user.uid;

      // 1. Encode new photo to Base64 if user picked one
      if (_newImageFile != null) {
        await _firebase.uploadProfilePhoto(uid, _newImageFile!);
      }

      // 2. Remove photo if user cleared it
      final hadPhoto = widget.user.photoBase64 != null || widget.user.photoUrl != null;
      if (_newImageFile == null && _existingPhoto == null && hadPhoto) {
        await _firebase.removeProfilePhoto(uid, '');
      }

      // 3. Save text fields
      await _firebase.updateUserFields(uid, {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Returns the ImageProvider to show in the avatar:
  ///   1. Newly picked local file
  ///   2. Existing Base64 data URI
  ///   3. Legacy network URL
  ImageProvider? _resolveAvatarImage() {
    if (_newImageFile != null) return FileImage(_newImageFile!);
    if (_existingPhoto == null) return null;
    if (_existingPhoto!.startsWith('data:')) {
      final base64Str = _existingPhoto!.split(',').last;
      return MemoryImage(base64Decode(base64Str));
    }
    return NetworkImage(_existingPhoto!);
  }

  @override
  Widget build(BuildContext context) {
    final avatarImage = _resolveAvatarImage();

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
                  GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: AppTheme.lightOrange,
                        shape: BoxShape.circle,
                        image: avatarImage != null
                            ? DecorationImage(image: avatarImage, fit: BoxFit.cover)
                            : null,
                      ),
                      child: avatarImage == null
                          ? const Icon(Icons.person_rounded, color: AppTheme.primaryOrange, size: 50)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImageSourceSheet,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildField('Full Name', _nameCtrl,
                validator: (v) => v!.trim().isEmpty ? 'Name is required' : null),
            const SizedBox(height: 14),
            _buildField('Email', _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                }),
            const SizedBox(height: 14),
            _buildField('Phone', _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            style: const TextStyle(fontSize: 13, color: AppTheme.greyText, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  MY ADDRESSES SCREEN — real-time Firestore stream
// ════════════════════════════════════════════════════════════════════════════
class MyAddressesScreen extends StatelessWidget {
  final String uid;
  const MyAddressesScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    final firebase = FirebaseService();

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar('My Addresses'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryOrange,
        onPressed: () => _showAddDialog(context, firebase),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<UserAddress>>(
        stream: firebase.addressStream(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange));
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final addresses = snap.data ?? [];
          if (addresses.isEmpty) {
            return const Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.location_off_rounded, size: 48, color: AppTheme.greyText),
                SizedBox(height: 12),
                Text('No addresses yet', style: TextStyle(color: AppTheme.greyText)),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: addresses.length,
            itemBuilder: (_, i) {
              final a = addresses[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(color: AppTheme.lightOrange, shape: BoxShape.circle),
                    child: const Icon(Icons.location_on, color: AppTheme.primaryOrange),
                  ),
                  title: Text(a.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(a.address),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => firebase.deleteAddress(uid, a.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, FirebaseService firebase) {
    final labelCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: labelCtrl,
                decoration: const InputDecoration(hintText: 'Label (Home, Work...)')),
            const SizedBox(height: 10),
            TextField(controller: addressCtrl,
                decoration: const InputDecoration(hintText: 'Full address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (addressCtrl.text.isNotEmpty) {
                await firebase.addAddress(uid, UserAddress(
                  id: '',
                  label: labelCtrl.text.isEmpty ? 'Other' : labelCtrl.text,
                  address: addressCtrl.text,
                ));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  PAYMENT METHODS SCREEN (UI only — payment backend is a separate integration)
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
                boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: ListTile(
                leading: Container(width: 44, height: 44,
                    decoration: const BoxDecoration(color: AppTheme.lightOrange, shape: BoxShape.circle),
                    child: Icon(card['icon'] as IconData, color: AppTheme.primaryOrange)),
                title: Text(card['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('•••• •••• •••• ${card['last4']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => _cards.removeAt(e.key)),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add card feature coming soon'))),
            icon: const Icon(Icons.add, color: AppTheme.primaryOrange),
            label: const Text('Add New Card', style: TextStyle(color: AppTheme.primaryOrange)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.primaryOrange),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SETTINGS SCREEN — every toggle persists to Firestore
// ════════════════════════════════════════════════════════════════════════════
class SettingsScreen extends StatefulWidget {
  final UserModel user;
  const SettingsScreen({super.key, required this.user});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _firebase = FirebaseService();
  final _auth = AuthService();

  late bool _notifications;
  late bool _emailUpdates;
  late bool _darkMode;
  late bool _locationAccess;

  @override
  void initState() {
    super.initState();
    _notifications = widget.user.pushNotifications;
    _emailUpdates = widget.user.emailUpdates;
    _darkMode = widget.user.darkMode;
    _locationAccess = widget.user.locationAccess;
  }

  Future<void> _toggle(String key, bool value) async {
    await _firebase.updateSetting(widget.user.uid, key, value);
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'This will permanently delete your account and all your data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _auth.deleteAccount();
                // _AuthGate listens to authStateChanges and redirects
                // to LoginScreen automatically after deletion.
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar('Settings'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionLabel('Notifications'),
          _switchTile('Push Notifications', _notifications, (v) {
            setState(() => _notifications = v);
            _toggle('pushNotifications', v);
          }),
          _switchTile('Email Updates', _emailUpdates, (v) {
            setState(() => _emailUpdates = v);
            _toggle('emailUpdates', v);
          }),
          const SizedBox(height: 16),
          _sectionLabel('Preferences'),
          _switchTile('Dark Mode', _darkMode, (v) {
            setState(() => _darkMode = v);
            _toggle('darkMode', v);
          }),
          _switchTile('Location Access', _locationAccess, (v) {
            setState(() => _locationAccess = v);
            _toggle('locationAccess', v);
          }),
          const SizedBox(height: 16),
          _sectionLabel('Account'),
          _actionTile('Change Password', Icons.lock_outline, () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Coming soon')));
          }),
          _actionTile('Delete Account', Icons.delete_forever_outlined,
              _confirmDeleteAccount, destructive: true),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13, color: AppTheme.greyText, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      );

  Widget _switchTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: AppTheme.darkText)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primaryOrange,
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
        boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Icon(icon, color: destructive ? Colors.red : AppTheme.primaryOrange),
        title: Text(label,
            style: TextStyle(fontWeight: FontWeight.w500, color: destructive ? Colors.red : AppTheme.darkText)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.greyText),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  HELP & SUPPORT SCREEN (unchanged)
// ════════════════════════════════════════════════════════════════════════════
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    {'q': 'How do I book a service?', 'a': 'Go to Home, browse services, select one, choose a time slot, and confirm your booking.'},
    {'q': 'How do I cancel a booking?', 'a': 'Go to Bookings tab, find your booking and tap "Cancel". Cancellations are free up to 2 hours before.'},
    {'q': 'How do I add a payment method?', 'a': 'Go to Profile → Payment Methods → Add New Card and enter your card details.'},
    {'q': 'How do I change my address?', 'a': 'Go to Profile → My Addresses to add, edit or delete addresses.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar('Help & Support'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.primaryOrange, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: const [
                Icon(Icons.support_agent, color: Colors.white, size: 36),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chat with Us', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('We typically reply within minutes', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('FAQs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
          const SizedBox(height: 12),
          ..._faqs.map((faq) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: ExpansionTile(
                  title: Text(faq['q']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.darkText)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  iconColor: AppTheme.primaryOrange,
                  collapsedIconColor: AppTheme.greyText,
                  children: [Text(faq['a']!, style: const TextStyle(color: AppTheme.greyText, fontSize: 13))],
                ),
              )),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Email: support@sewamitra.com'))),
            icon: const Icon(Icons.email_outlined, color: AppTheme.primaryOrange),
            label: const Text('Email Support', style: TextStyle(color: AppTheme.primaryOrange)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.primaryOrange),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.darkText)),
      iconTheme: const IconThemeData(color: AppTheme.darkText),
    );

// ════════════════════════════════════════════════════════════════════════════
//  SHARED USER AVATAR — handles Base64 data URIs and legacy network URLs
// ════════════════════════════════════════════════════════════════════════════
class _UserAvatar extends StatelessWidget {
  final UserModel user;
  final double radius;
  const _UserAvatar({required this.user, this.radius = 45});

  ImageProvider? _resolveImage() {
    // Prefer Base64 stored in Firestore
    if (user.photoBase64 != null) {
      final base64Str = user.photoBase64!.split(',').last;
      return MemoryImage(base64Decode(base64Str));
    }
    // Fallback to legacy network URL
    if (user.photoUrl != null) {
      return NetworkImage(user.photoUrl!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage();
    final size = radius * 2;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.lightOrange,
        shape: BoxShape.circle,
        image: image != null
            ? DecorationImage(image: image, fit: BoxFit.cover)
            : null,
      ),
      child: image == null
          ? Icon(Icons.person_rounded, color: AppTheme.primaryOrange, size: radius)
          : null,
    );
  }
}
