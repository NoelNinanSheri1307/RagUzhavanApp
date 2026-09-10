import 'package:flutter/material.dart';
import '../models/farmer.dart';
import '../repositories/auth_repository.dart';

enum UserRole { guest, farmer, admin }

class AuthService extends ChangeNotifier {
  final AuthRepository _authRepository;
  UserRole _role = UserRole.farmer; // Default to farmer mode for prototype review
  Farmer? _currentFarmer;

  AuthService({AuthRepository? authRepository})
      : _authRepository = authRepository ?? MockAuthRepository() {
    _initFromRepository();
  }

  void _initFromRepository() {
    final user = _authRepository.currentUser;
    if (user != null) {
      _role = user.isAdmin ? UserRole.admin : UserRole.farmer;
      _currentFarmer = user.farmer ??
          Farmer(
            id: 'FARM-001',
            name: 'M. Palanisamy',
            phone: '+91 98421 88321',
            district: 'Thanjavur',
            block: 'Budalur',
            state: 'Tamil Nadu',
            preferredLanguage: 'ta',
            crops: ['Paddy / Rice', 'Blackgram'],
            landSizeAcres: 4.5,
            agroZone: 'Cauvery Delta Zone',
            season: 'Kuruvai',
            accountStatus: 'Active',
            lastActivity: DateTime.now(),
          );
    }
  }

  UserRole get role => _role;
  Farmer? get currentFarmer => _currentFarmer;
  bool get isLoggedIn => _role != UserRole.guest;
  bool get isFarmer => _role == UserRole.farmer;
  bool get isAdmin => _role == UserRole.admin;
  AuthRepository get repository => _authRepository;

  Future<bool> login({
    required String username,
    required String password,
    UserRole role = UserRole.farmer,
  }) async {
    final authRole = (role == UserRole.admin) ? AuthRole.admin : AuthRole.farmer;
    final user = await _authRepository.login(
      phoneOrUsername: username,
      password: password,
      role: authRole,
    );

    if (user != null) {
      _role = user.isAdmin ? UserRole.admin : UserRole.farmer;
      _currentFarmer = user.farmer;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> registerFarmer(Farmer farmer, {String password = 'password123'}) async {
    final user = await _authRepository.registerFarmer(farmer);
    _role = UserRole.farmer;
    _currentFarmer = user.farmer ?? farmer;
    notifyListeners();
    return true;
  }

  Future<void> loginAsAdmin() async {
    await login(username: 'admin', password: 'password', role: UserRole.admin);
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _role = UserRole.guest;
    _currentFarmer = null;
    notifyListeners();
  }

  void switchRole(UserRole newRole) {
    if (_role == newRole) return;
    _role = newRole;
    if (_role == UserRole.farmer && _currentFarmer == null) {
      _currentFarmer = Farmer(
        id: 'FARM-001',
        name: 'M. Palanisamy',
        phone: '+91 98421 88321',
        district: 'Thanjavur',
        block: 'Budalur',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Paddy / Rice'],
        landSizeAcres: 4.5,
        agroZone: 'Cauvery Delta Zone',
        season: 'Kuruvai',
        accountStatus: 'Active',
        lastActivity: DateTime.now(),
      );
    }
    notifyListeners();
  }
}
