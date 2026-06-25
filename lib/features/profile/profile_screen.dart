import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../services/payment_service.dart';
import '../../shared/models/user_model.dart';
import '../../shared/models/backend_models.dart';
import '../provider/join_provider_screen.dart';
import '../provider/earning_screen.dart';
import '../wallet/transaction_screen.dart';
import '../admin/user_management_screen.dart';
import '../provider/provider_management_screen.dart';
import '../profile/settings_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Loading...';
  String _email = '';
  String? _photoUrl;
  String? _photoBase64;
  String _role = 'customer';
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
          _photoBase64 = profile['photoBase64'];
          _role = profile['role'] ?? 'customer';
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
        _photoBase64 = result['photoBase64'] ?? _photoBase64;
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
              Navigator.of(context, rootNavigator: true).pop();
              await AuthService.signOut();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    if (_photoBase64 != null && _photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(_photoBase64!.split(',').last);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return Image.network(_photoUrl!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person_rounded, color: AppTheme.primaryOrange, size: 50));
    }
    return const Icon(Icons.person_rounded, color: AppTheme.primaryOrange, size: 50);
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
                          color: AppTheme.lightOrange, shape: BoxShape.circle),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(45),
                        child: _buildAvatar(),
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
                        style: const TextStyle(fontSize: 14, color: AppTheme.greyText)),
                    const SizedBox(height: 28),

                    // ── Menu items ──────────────────────────────────────────
                    _ProfileTile(
                      icon: Icons.edit_rounded,
                      label: 'Edit Profile',
                      onTap: () => _navigateTo(
                        EditProfileScreen(
                            name: _name, email: _email, photoUrl: _photoUrl, photoBase64: _photoBase64),
                      ),
                    ),

                    // Customer & Provider only
                    if (_role != 'admin') ...[
                      if (_role == 'customer')
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
                      if (_role == 'provider')
                        _ProfileTile(
                          icon: Icons.analytics_outlined,
                          label: 'My Earnings',
                          onTap: () => _navigateTo(const EarningScreen()),
                        ),
                    ],

                    // Admin only
                    if (_role == 'admin') ...[
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
                    ],

                    // Common for all roles
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

// ══════════════════════════════════════════════════════════════════════════════
//  SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

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
          BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2)),
        ],
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

AppBar _buildAppBar(String title) => AppBar(
      backgroundColor: AppTheme.bgColor,
      elevation: 0,
      centerTitle: true,
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.darkText)),
      iconTheme: const IconThemeData(color: AppTheme.darkText),
    );

// ══════════════════════════════════════════════════════════════════════════════
//  EDIT PROFILE SCREEN — fully connected to Firestore
// ══════════════════════════════════════════════════════════════════════════════

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final String? photoBase64;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
    this.photoUrl,
    this.photoBase64,
  });

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
  String? _currentPhotoBase64;
  bool _isSaving = false;
  bool _isLoadingPhone = true;

  final _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.name);
    _emailCtrl = TextEditingController(text: widget.email);
    _phoneCtrl = TextEditingController();
    _currentPhotoUrl = widget.photoUrl;
    _currentPhotoBase64 = widget.photoBase64;
    _loadPhoneFromFirestore();
  }

  Future<void> _loadPhoneFromFirestore() async {
    final uid = AuthService.currentUser?.uid;
    if (uid != null) {
      final user = await _firebaseService.getUser(uid);
      if (mounted) {
        setState(() {
          _phoneCtrl.text = user?.phone ?? '';
          _isLoadingPhone = false;
        });
      }
    } else {
      setState(() => _isLoadingPhone = false);
    }
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final uid = AuthService.currentUser?.uid;
      if (uid == null) throw Exception('Not signed in');

      String? newPhotoBase64 = _currentPhotoBase64;
      String? newPhotoUrl = _currentPhotoUrl;

      // Upload photo as Base64 if a new image was picked
      if (_imageFile != null) {
        newPhotoBase64 = await _firebaseService.uploadProfilePhoto(uid, _imageFile!);
        newPhotoUrl = null; // clear old URL, base64 takes priority
      }

      // Update Firestore (fullName, phone, photo)
      await _firebaseService.updateUserFields(uid, {
        'fullName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        if (newPhotoBase64 != null) 'photoBase64': newPhotoBase64,
        if (newPhotoUrl != null) 'photoUrl': newPhotoUrl,
      });

      // Also update Firebase Auth display name
      await AuthService.updateProfile(fullName: _nameCtrl.text.trim());

      if (mounted) {
        Navigator.pop(context, {
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'photoUrl': newPhotoUrl,
          'photoBase64': newPhotoBase64,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildPhotoWidget() {
    if (_imageFile != null) return Image.file(_imageFile!, fit: BoxFit.cover);
    if (_currentPhotoBase64 != null && _currentPhotoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(_currentPhotoBase64!.split(',').last);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      return Image.network(_currentPhotoUrl!, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.person_rounded, color: AppTheme.primaryOrange, size: 50));
    }
    return const Icon(Icons.person_rounded, color: AppTheme.primaryOrange, size: 50);
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
                        child: _buildPhotoWidget(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                            color: AppTheme.primaryOrange, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildField('Full Name', _nameCtrl,
                validator: (v) => v!.trim().isEmpty ? 'Name is required' : null),
            const SizedBox(height: 14),
            _buildField('Email', _emailCtrl,
                enabled: false, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _isLoadingPhone
                ? const Center(child: CircularProgressIndicator())
                : _buildField('Phone', _phoneCtrl, keyboardType: TextInputType.phone),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                fontSize: 13, color: AppTheme.greyText, fontWeight: FontWeight.w500)),
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
                borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  MY ADDRESSES SCREEN — Firestore backed with real-time stream
// ══════════════════════════════════════════════════════════════════════════════

class MyAddressesScreen extends StatefulWidget {
  const MyAddressesScreen({super.key});

  @override
  State<MyAddressesScreen> createState() => _MyAddressesScreenState();
}

class _MyAddressesScreenState extends State<MyAddressesScreen> {
  final _firebaseService = FirebaseService();
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = AuthService.currentUser?.uid;
  }

  void _addAddressDialog() {
    final addressCtrl = TextEditingController();
    String selectedLabel = 'Home';
    final labels = ['Home', 'Work', 'Other'];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label picker
              Wrap(
                spacing: 8,
                children: labels.map((l) {
                  final selected = selectedLabel == l;
                  return ChoiceChip(
                    label: Text(l),
                    selected: selected,
                    selectedColor: AppTheme.lightOrange,
                    onSelected: (_) => setDialogState(() => selectedLabel = l),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  hintText: 'Enter full address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
              onPressed: () async {
                if (addressCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                if (_uid != null) {
                  try {
                    await _firebaseService.addAddress(
                      _uid!,
                      UserAddress(
                        id: '',
                        label: selectedLabel,
                        address: addressCtrl.text.trim(),
                      ),
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add address: $e')),
                      );
                    }
                  }
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAddress(String addressId) async {
    if (_uid == null) return;
    try {
      await _firebaseService.deleteAddress(_uid!, addressId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar('My Addresses'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryOrange,
        onPressed: _addAddressDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _uid == null
          ? const Center(child: Text('Not signed in'))
          : StreamBuilder<List<UserAddress>>(
              stream: _firebaseService.addressStream(_uid!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final addresses = snapshot.data ?? [];
                if (addresses.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_outlined, size: 60, color: AppTheme.greyText),
                        SizedBox(height: 12),
                        Text('No addresses saved yet',
                            style: TextStyle(color: AppTheme.greyText)),
                      ],
                    ),
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
                          child: const Icon(Icons.location_on, color: AppTheme.primaryOrange),
                        ),
                        title: Text(a.label,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(a.address),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _deleteAddress(a.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  PAYMENT METHODS SCREEN — real saved cards from Firestore
// ══════════════════════════════════════════════════════════════════════════════

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _paymentService = PaymentService();
  bool _isDeleting = false;

  void _addCardDialog() {
    final cardNumberCtrl = TextEditingController();
    final holderCtrl = TextEditingController();
    final expiryCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();
    bool isSaving = false;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Card'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField('Card Number', cardNumberCtrl,
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.length < 16 ? 'Enter valid card number' : null),
                  const SizedBox(height: 10),
                  _dialogField('Card Holder Name', holderCtrl,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _dialogField('Expiry (MM/YY)', expiryCtrl,
                            validator: (v) => v!.isEmpty ? 'Required' : null),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dialogField('CVV', cvvCtrl,
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.length < 3 ? 'Invalid' : null),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSaving = true);
                      final success = await _paymentService.saveCard(
                        cardNumber: cardNumberCtrl.text.trim(),
                        cardHolderName: holderCtrl.text.trim(),
                        expiryDate: expiryCtrl.text.trim(),
                        cvv: cvvCtrl.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted && !success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to save card')),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(String hint, TextEditingController ctrl,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  IconData _cardIcon(String type) {
    switch (type.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card_outlined;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: _buildAppBar('Payment Methods'),
      body: StreamBuilder<List<SavedCardModel>>(
        stream: _paymentService.getSavedCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cards = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (cards.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: const [
                      Icon(Icons.credit_card_off_outlined,
                          size: 60, color: AppTheme.greyText),
                      SizedBox(height: 12),
                      Text('No saved cards', style: TextStyle(color: AppTheme.greyText)),
                    ],
                  ),
                ),
              ...cards.map((card) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(14),
                    border: card.isDefault
                        ? Border.all(color: AppTheme.primaryOrange, width: 1.5)
                        : null,
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
                      child: Icon(_cardIcon(card.cardType), color: AppTheme.primaryOrange),
                    ),
                    title: Row(
                      children: [
                        Text(card.cardType.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (card.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.lightOrange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Default',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primaryOrange,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                    subtitle: Text('${card.cardNumber}  •  Exp: ${card.expiryDate}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'default') {
                          await _paymentService.setDefaultCard(card.id);
                        } else if (value == 'delete') {
                          setState(() => _isDeleting = true);
                          await _paymentService.deleteCard(card.id);
                          setState(() => _isDeleting = false);
                        }
                      },
                      itemBuilder: (_) => [
                        if (!card.isDefault)
                          const PopupMenuItem(
                              value: 'default', child: Text('Set as Default')),
                        const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _addCardDialog,
                icon: const Icon(Icons.add, color: AppTheme.primaryOrange),
                label: const Text('Add New Card',
                    style: TextStyle(color: AppTheme.primaryOrange)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.primaryOrange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const _faqs = [
    {
      'q': 'How do I book a service?',
      'a': 'Go to Home, browse services, select one, choose a time slot, and confirm your booking.'
    },
    {
      'q': 'How do I cancel a booking?',
      'a': 'Go to Bookings tab, find your booking and tap "Cancel". Cancellations are free up to 2 hours before.'
    },
    {
      'q': 'How do I add a payment method?',
      'a': 'Go to Profile → Payment Methods → Add New Card and enter your card details.'
    },
    {
      'q': 'How do I change my address?',
      'a': 'Go to Profile → My Addresses to add, edit or delete addresses.'
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
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('FAQs',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
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
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                iconColor: AppTheme.primaryOrange,
                collapsedIconColor: AppTheme.greyText,
                children: [
                  Text(faq['a']!, style: const TextStyle(color: AppTheme.greyText, fontSize: 13))
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email: support@sewamitra.com'))),
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
