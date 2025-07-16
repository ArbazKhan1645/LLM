enum UserType { user, business }

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final UserType userType;
  final String? businessName;
  final String? businessLink;
  final String? businessAddress;
  final String? professionalStatus;
  final String? industry;
  final bool isEmailVerified;
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final String? fcmToken;
  final String? deviceType;
  final DateTime? lastSeen;
  final bool? isOnline;
  final String? avatar;
  final String? shopifyAccessToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.userType,
    this.businessName,
    this.businessLink,
    this.businessAddress,
    this.professionalStatus,
    this.industry,
    required this.isEmailVerified,
    required this.isProfileComplete,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    this.fcmToken,
    this.deviceType,
    this.lastSeen,
    this.isOnline,
    this.shopifyAccessToken,
    this.avatar,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'userType': userType.toString(),
      'businessName': businessName,
      'businessLink': businessLink,
      'businessAddress': businessAddress,
      'professionalStatus': professionalStatus,
      'industry': industry,
      'isEmailVerified': isEmailVerified,
      'isProfileComplete': isProfileComplete,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deviceId': deviceId,
      'fcmToken': fcmToken,
      'deviceType': deviceType,
      'lastSeen': lastSeen?.toIso8601String(),
      'isOnline': isOnline,
      'avatar': avatar,
      'shopifyAccessToken'  : shopifyAccessToken


    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: _parseString(json['uid']) ?? '',
      email: _parseString(json['email']) ?? '',
      fullName: _parseString(json['fullName']) ?? '',
      userType: _parseUserType(json['userType']),
      businessName: _parseString(json['businessName']),
      businessLink: _parseString(json['businessLink']),
      businessAddress: _parseString(json['businessAddress']),
      professionalStatus: _parseString(json['professionalStatus']),
      industry: _parseString(json['industry']),
      isEmailVerified: _parseBool(json['isEmailVerified']) ?? false,
      isProfileComplete: _parseBool(json['isProfileComplete']) ?? false,
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.now(),
      deviceId: _parseString(json['deviceId']) ?? '',
      fcmToken: _parseString(json['fcmToken']),
      deviceType: _parseString(json['deviceType']),
      lastSeen: _parseDateTime(json['lastSeen']),
      isOnline: _parseBool(json['isOnline']),
      avatar: _parseString(json['avatar']),
      shopifyAccessToken: _parseString(json['shopifyAccessToken'])
    );
  }

  // Helper methods for parsing different data types
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value.isEmpty ? null : value;
    }
    return value.toString();
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      if (lowerValue == 'true' || lowerValue == '1') return true;
      if (lowerValue == 'false' || lowerValue == '0') return false;
    }
    if (value is int) {
      return value == 1;
    }
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    // Handle DateTime object
    if (value is DateTime) return value;
    
    // Handle Timestamp (Firebase)
    if (value.runtimeType.toString() == 'Timestamp') {
      try {
        // Firebase Timestamp has toDate() method
        return (value as dynamic).toDate();
      } catch (e) {
        // Fallback if toDate() fails
        try {
          final seconds = (value as dynamic).seconds;
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        } catch (e) {
          return null;
        }
      }
    }
    
    // Handle String
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    
    // Handle int (Unix timestamp)
    if (value is int) {
      try {
        // Check if it's in seconds or milliseconds
        if (value > 1000000000000) {
          // Milliseconds
          return DateTime.fromMillisecondsSinceEpoch(value);
        } else {
          // Seconds
          return DateTime.fromMillisecondsSinceEpoch(value * 1000);
        }
      } catch (e) {
        return null;
      }
    }
    
    // Handle Map (for complex timestamp objects)
    if (value is Map<String, dynamic>) {
      try {
        // Check for Firebase Timestamp structure
        if (value.containsKey('seconds')) {
          final seconds = value['seconds'] as int;
          final nanoseconds = value['nanoseconds'] as int? ?? 0;
          return DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds / 1000000).round()
          );
        }
        
        // Check for other timestamp formats
        if (value.containsKey('_seconds')) {
          final seconds = value['_seconds'] as int;
          return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        }
      } catch (e) {
        return null;
      }
    }
    
    return null;
  }

  static UserType _parseUserType(dynamic value) {
    if (value == null) return UserType.user;
    
    String typeString = value.toString().toLowerCase();
    
    // Handle enum string format like "UserType.business"
    if (typeString.contains('.')) {
      typeString = typeString.split('.').last;
    }
    
    switch (typeString) {
      case 'business':
        return UserType.business;
      case 'user':
      default:
        return UserType.user;
    }
  }

  String get initials {
    final names = fullName.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  // Copy with method for easy updates
  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    UserType? userType,
    String? businessName,
    String? businessLink,
    String? businessAddress,
    String? professionalStatus,
    String? industry,
    bool? isEmailVerified,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deviceId,
    String? fcmToken,
    String? deviceType,
    DateTime? lastSeen,
    bool? isOnline,
    String? shopifyAccessToken,
    String? avatar,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      userType: userType ?? this.userType,
      businessName: businessName ?? this.businessName,
      businessLink: businessLink ?? this.businessLink,
      businessAddress: businessAddress ?? this.businessAddress,
      professionalStatus: professionalStatus ?? this.professionalStatus,
      industry: industry ?? this.industry,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      fcmToken: fcmToken ?? this.fcmToken,
      deviceType: deviceType ?? this.deviceType,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      avatar: avatar ?? this.avatar,
      shopifyAccessToken: shopifyAccessToken ?? this.shopifyAccessToken
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, fullName: $fullName, userType: $userType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}