// lib/models/user_model.dart

class UserAddress {
  final String id;
  final String label; // 'Home', 'Work', 'Other'
  final String address;

  UserAddress({required this.id, required this.label, required this.address});

  factory UserAddress.fromMap(Map<String, dynamic> map, String id) {
    return UserAddress(
      id: id,
      label: map['label'] ?? 'Other',
      address: map['address'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'label': label,
        'address': address,
      };
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;

  /// Legacy network URL (kept for backward compat) — prefer photoBase64 going forward.
  final String? photoUrl;

  /// Base64 data URI, e.g. "data:image/jpeg;base64,..."
  /// Stored directly in Firestore — no Storage bucket needed.
  final String? photoBase64;

  // Settings
  final bool pushNotifications;
  final bool emailUpdates;
  final bool darkMode;
  final bool locationAccess;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.photoBase64,
    this.pushNotifications = true,
    this.emailUpdates = false,
    this.darkMode = false,
    this.locationAccess = true,
  });

  /// Returns whichever photo source is available (Base64 takes priority).
  bool get hasPhoto => photoBase64 != null || photoUrl != null;

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      photoBase64: map['photoBase64'],
      pushNotifications: map['pushNotifications'] ?? true,
      emailUpdates: map['emailUpdates'] ?? false,
      darkMode: map['darkMode'] ?? false,
      locationAccess: map['locationAccess'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'phone': phone,
        'photoUrl': photoUrl,
        'photoBase64': photoBase64,
        'pushNotifications': pushNotifications,
        'emailUpdates': emailUpdates,
        'darkMode': darkMode,
        'locationAccess': locationAccess,
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? photoBase64,
    bool? pushNotifications,
    bool? emailUpdates,
    bool? darkMode,
    bool? locationAccess,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      photoBase64: photoBase64 ?? this.photoBase64,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailUpdates: emailUpdates ?? this.emailUpdates,
      darkMode: darkMode ?? this.darkMode,
      locationAccess: locationAccess ?? this.locationAccess,
    );
  }
}
