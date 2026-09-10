import 'package:flutter/material.dart';
import '../models/farmer.dart';

enum UserRole { guest, farmer, admin }

class AuthService extends ChangeNotifier {
  UserRole _role = UserRole.farmer; // Default to farmer mode for hackathon review
  Farmer? _currentFarmer = const Farmer(
    id: 'FARM-001',
    name: 'M. Palanisamy',
    phone: '+91 98421 88321',
    district: 'Thanjavur',
    state: 'Tamil Nadu',
    preferredLanguage: 'ta',
    crops: ['Paddy', 'Blackgram'],
    landSizeAcres: 4.5,
    agroZone: 'Cauvery Delta Zone',
  );

  UserRole get role => _role;
  Farmer? get currentFarmer => _currentFarmer;
  bool get isLoggedIn => _role != UserRole.guest;
  bool get isFarmer => _role == UserRole.farmer;
  bool get isAdmin => _role == UserRole.admin;

  void loginAsFarmer(Farmer farmer) {
    _role = UserRole.farmer;
    _currentFarmer = farmer;
    notifyListeners();
  }

  void loginAsAdmin() {
    _role = UserRole.admin;
    _currentFarmer = null;
    notifyListeners();
  }

  void logout() {
    _role = UserRole.guest;
    _currentFarmer = null;
    notifyListeners();
  }

  void switchRole(UserRole newRole) {
    if (_role == newRole) return;
    _role = newRole;
    if (_role == UserRole.farmer && _currentFarmer == null) {
      _currentFarmer = const Farmer(
        id: 'FARM-001',
        name: 'M. Palanisamy',
        phone: '+91 98421 88321',
        district: 'Thanjavur',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Paddy'],
        landSizeAcres: 4.5,
        agroZone: 'Cauvery Delta Zone',
      );
    }
    notifyListeners();
  }
}
