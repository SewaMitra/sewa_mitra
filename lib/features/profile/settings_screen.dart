// Drop this file into lib/features/profile/settings_screen.dart
// and import it in profile_screen.dart instead of the inline class.
//
// pubspec.yaml — make sure you have:
//   permission_handler: ^11.3.1   (or latest)

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_service.dart';
import '../../viewmodels/theme_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _firebaseService = FirebaseService();
  String? _uid;

  bool _notifications = true;
  bool _emailUpdates = false;
  bool _locationAccess = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _uid = AuthService.currentUser?.uid;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load Firestore prefs
    if (_uid != null) {
      try {
        final user = await _firebaseService.getUser(_uid!);
        if (mounted && user != null) {
          setState(() {
            _notifications = user.pushNotifications;
            _emailUpdates = user.emailUpdates;
          });
        }
      } catch (_) {}
    }

    // Load actual location permission status from OS
    final locationStatus = await Permission.location.status;
    if (mounted) {
      setState(() {
        _locationAccess = locationStatus.isGranted;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    if (_uid == null) return;
    try {
      await _firebaseService.updateSetting(_uid!, key, value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    }
  }

  // ── Location permission ────────────────────────────────────────────────────
  Future<void> _handleLocationToggle(bool value) async {
    if (value) {
      // Request permission
      final status = await Permission.location.request();
      if (mounted) {
        setState(() => _locationAccess = status.isGranted);
        if (status.isPermanentlyDenied) {
          _showOpenSettingsDialog();
        } else if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
      }
    } else {
      // Can't revoke programmatically — send user to app settings
      setState(() => _locationAccess = false);
      _showOpenSettingsDialog(revoking: true);
    }

    // Persist actual state
    await _updateSetting('locationAccess', _locationAccess);
  }

  void _showOpenSettingsDialog({bool revoking = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(revoking ? 'Disable Location' : 'Permission Required'),
        content: Text(revoking
            ? 'To disable location access, please go to App Settings and revoke the permission manually.'
            : 'Location permission was denied. Please enable it in App Settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Change Password ────────────────────────────────────────────────────────
  void _showChangePasswordDialog() {
    final user = FirebaseAuth.instance.currentUser;
    final isGoogleUser = user?.providerData
            .any((p) => p.providerId == 'google.com') ??
        false;

    if (isGoogleUser) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Change Password'),
          content: const Text(
              'You signed in with Google. Password changes must be made through your Google account.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Email/password user — show reset email dialog
    showDialog(
      context: context,
      builder: (_) => _ChangePasswordDialog(email: user?.email ?? ''),
    );
  }

  // ── Delete Account ─────────────────────────────────────────────────────────
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'This will permanently delete your account and all your data. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
                await AuthService.signOut();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Failed to delete account. Please re-login and try again.')),
                  );
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
    final themeVM = context.watch<ThemeViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Notifications ──────────────────────────────────────────
                _sectionLabel('Notifications'),
                _switchTile(
                  'Push Notifications',
                  _notifications,
                  isDark,
                  (v) {
                    setState(() => _notifications = v);
                    _updateSetting('pushNotifications', v);
                  },
                ),
                _switchTile(
                  'Email Updates',
                  _emailUpdates,
                  isDark,
                  (v) {
                    setState(() => _emailUpdates = v);
                    _updateSetting('emailUpdates', v);
                  },
                ),
                const SizedBox(height: 16),

                // ── Preferences ────────────────────────────────────────────
                _sectionLabel('Preferences'),
                _switchTile(
                  'Dark Mode',
                  themeVM.isDarkMode,
                  isDark,
                  (v) => themeVM.setDarkMode(v), // updates app theme + Firestore
                ),
                _switchTile(
                  'Location Access',
                  _locationAccess,
                  isDark,
                  _handleLocationToggle, // real OS permission
                ),
                const SizedBox(height: 16),

                // ── Account ────────────────────────────────────────────────
                _sectionLabel('Account'),
                _actionTile('Change Password', Icons.lock_outline, isDark,
                    _showChangePasswordDialog),
                _actionTile(
                  'Delete Account',
                  Icons.delete_forever_outlined,
                  isDark,
                  _showDeleteAccountDialog,
                  destructive: true,
                ),
              ],
            ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
      );

  Widget _switchTile(
      String label, bool value, bool isDark, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: SwitchListTile(
        title: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface)),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _actionTile(
      String label, IconData icon, bool isDark, VoidCallback onTap,
      {bool destructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                color: destructive ? Colors.red : Theme.of(context).colorScheme.onSurface)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  CHANGE PASSWORD DIALOG
// ══════════════════════════════════════════════════════════════════════════════

class _ChangePasswordDialog extends StatefulWidget {
  final String email;
  const _ChangePasswordDialog({required this.email});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  bool _sending = false;
  bool _sent = false;

  Future<void> _sendReset() async {
    setState(() => _sending = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      if (mounted) setState(() { _sending = false; _sent = true; });
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: _sent
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mark_email_read_outlined,
                    color: Colors.green, size: 48),
                const SizedBox(height: 12),
                Text(
                  'A password reset link has been sent to:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'We\'ll send a password reset link to your email address.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryOrange),
                ),
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_sent ? 'Done' : 'Cancel'),
        ),
        if (!_sent)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange),
            onPressed: _sending ? null : _sendReset,
            child: _sending
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Send Link',
                    style: TextStyle(color: Colors.white)),
          ),
      ],
    );
  }
}
