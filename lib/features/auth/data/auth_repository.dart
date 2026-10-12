import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  final String phone;
  final String role;
  final String primaryShopId;
  final DateTime joinedAt;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phone = '+1 (555) 234-5678',
    this.role = 'Store Administrator',
    this.primaryShopId = 'shop_flagship',
    required this.joinedAt,
  });

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phone,
    String? role,
    String? primaryShopId,
    DateTime? joinedAt,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      primaryShopId: primaryShopId ?? this.primaryShopId,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}

abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> updateProfile({
    required String displayName,
    String? phone,
    String? primaryShopId,
  });
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  AuthUser? get currentUser;
}

class MockAuthRepository implements AuthRepository {
  static const defaultEmail = 'asd@gmail.com';
  static const defaultPassword = 'Asd@123';

  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  MockAuthRepository() {
    // Starts pre-authenticated for seamless prototype interaction
    _currentUser = AuthUser(
      uid: 'user_demo_101',
      email: defaultEmail,
      displayName: 'Store Manager',
      phone: '+1 (555) 234-5678',
      role: 'Store Administrator',
      primaryShopId: 'shop_flagship',
      joinedAt: DateTime(2025, 1, 15),
    );
  }

  @override
  Stream<AuthUser?> get authStateChanges async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = AuthUser(
      uid: 'user_demo_101',
      email: email.trim().isEmpty ? defaultEmail : email.trim(),
      displayName: 'Store Manager',
      phone: '+1 (555) 234-5678',
      role: 'Store Administrator',
      primaryShopId: 'shop_flagship',
      joinedAt: DateTime(2025, 1, 15),
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> createUserWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = AuthUser(
      uid: 'user_demo_101',
      email: email.trim().isEmpty ? defaultEmail : email.trim(),
      displayName: 'Store Manager',
      phone: '+1 (555) 234-5678',
      role: 'Store Administrator',
      primaryShopId: 'shop_flagship',
      joinedAt: DateTime.now(),
    );
    _controller.add(_currentUser);
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    String? phone,
    String? primaryShopId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        displayName: displayName.trim(),
        phone: phone?.trim(),
        primaryShopId: primaryShopId,
      );
      _controller.add(_currentUser);
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    // Simulated successful password update
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}

// Global singleton instance so auth state is preserved across screens
final _mockAuthInstance = MockAuthRepository();

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return _mockAuthInstance;
});

final authStateChangesProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
