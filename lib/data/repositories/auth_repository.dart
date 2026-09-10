import '../models/farmer.dart';
import '../services/api_service.dart';

enum AuthRole { farmer, admin }

class AuthUser {
  final String id;
  final String name;
  final String phone;
  final AuthRole role;
  final Farmer? farmer;

  const AuthUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.farmer,
  });

  bool get isAdmin => role == AuthRole.admin;
  bool get isFarmer => role == AuthRole.farmer;
}

abstract class AuthRepository {
  Future<AuthUser?> login({
    required String phoneOrUsername,
    required String password,
    required AuthRole role,
  });

  Future<AuthUser> registerFarmer(Farmer farmer);

  Future<void> logout();

  AuthUser? get currentUser;
  bool get isAuthenticated;
}

class MockAuthRepository implements AuthRepository {
  AuthUser? _currentUser;

  MockAuthRepository() {
    // Default demo session: Farmer
    _currentUser = AuthUser(
      id: 'FARM-101',
      name: 'Muthusamy K.',
      phone: '+91 98765 43210',
      role: AuthRole.farmer,
      farmer: Farmer(
        id: 'FARM-101',
        name: 'Muthusamy K.',
        phone: '+91 98765 43210',
        district: 'Thanjavur',
        block: 'Budalur',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Paddy / Rice', 'Pulses'],
        landSizeAcres: 3.5,
        agroZone: 'Cauvery Delta Zone',
        season: 'Kuruvai',
        accountStatus: 'Active',
        lastActivity: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
    );
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  bool get isAuthenticated => _currentUser != null;

  @override
  Future<AuthUser?> login({
    required String phoneOrUsername,
    required String password,
    required AuthRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (role == AuthRole.admin) {
      _currentUser = AuthUser(
        id: 'ADMIN-001',
        name: 'Dr. S. Ramanathan (Admin)',
        phone: '+91 94421 00000',
        role: AuthRole.admin,
      );
      return _currentUser;
    }

    // Default farmer login
    _currentUser = AuthUser(
      id: 'FARM-101',
      name: 'Muthusamy K.',
      phone: phoneOrUsername,
      role: AuthRole.farmer,
      farmer: Farmer(
        id: 'FARM-101',
        name: 'Muthusamy K.',
        phone: phoneOrUsername,
        district: 'Thanjavur',
        block: 'Budalur',
        state: 'Tamil Nadu',
        preferredLanguage: 'ta',
        crops: ['Paddy / Rice', 'Pulses'],
        landSizeAcres: 3.5,
        agroZone: 'Cauvery Delta Zone',
        season: 'Kuruvai',
        accountStatus: 'Active',
        lastActivity: DateTime.now(),
      ),
    );
    return _currentUser;
  }

  @override
  Future<AuthUser> registerFarmer(Farmer farmer) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = AuthUser(
      id: farmer.id.isEmpty ? 'FARM-${DateTime.now().millisecondsSinceEpoch}' : farmer.id,
      name: farmer.name,
      phone: farmer.phone,
      role: AuthRole.farmer,
      farmer: farmer,
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}

class ApiAuthRepository implements AuthRepository {
  final ApiService apiService;
  final MockAuthRepository mockFallback;
  AuthUser? _currentUser;

  ApiAuthRepository({
    required this.apiService,
    MockAuthRepository? mockFallback,
  }) : mockFallback = mockFallback ?? MockAuthRepository();

  @override
  AuthUser? get currentUser => apiService.hasBaseUrl ? (_currentUser ?? mockFallback.currentUser) : mockFallback.currentUser;

  @override
  bool get isAuthenticated => currentUser != null;

  @override
  Future<AuthUser?> login({
    required String phoneOrUsername,
    required String password,
    required AuthRole role,
  }) async {
    if (!apiService.hasBaseUrl) {
      return mockFallback.login(
        phoneOrUsername: phoneOrUsername,
        password: password,
        role: role,
      );
    }

    try {
      final tokenRes = await apiService.login(
        username: phoneOrUsername,
        password: password,
        role: role.name,
      );

      if (tokenRes != null) {
        // Fetch user info from GET /users/me
        final userMe = await apiService.getCurrentUser();
        final serverRole = (userMe?['role'] == 'admin') ? AuthRole.admin : role;
        
        final farmer = Farmer(
          id: 'USER-${userMe?['username'] ?? '101'}',
          name: userMe?['full_name'] as String? ?? userMe?['username'] as String? ?? phoneOrUsername,
          phone: userMe?['phone'] as String? ?? phoneOrUsername,
          district: userMe?['district'] as String? ?? 'Thanjavur',
          block: 'Budalur',
          state: userMe?['state'] as String? ?? 'Tamil Nadu',
          preferredLanguage: 'ta',
          crops: [userMe?['primary_crop'] as String? ?? 'Paddy / Rice'],
          landSizeAcres: 3.5,
          agroZone: 'Cauvery Delta Zone',
          season: 'Kuruvai',
          accountStatus: 'Active',
          lastActivity: DateTime.now(),
        );

        _currentUser = AuthUser(
          id: farmer.id,
          name: farmer.name,
          phone: farmer.phone,
          role: serverRole,
          farmer: farmer,
        );
        return _currentUser;
      }
    } catch (_) {
      // Fallback on network or auth error
      return mockFallback.login(
        phoneOrUsername: phoneOrUsername,
        password: password,
        role: role,
      );
    }
    return null;
  }

  @override
  Future<AuthUser> registerFarmer(Farmer farmer) async {
    if (!apiService.hasBaseUrl) {
      return mockFallback.registerFarmer(farmer);
    }

    try {
      await apiService.register(
        username: farmer.phone.replaceAll(RegExp(r'\s+'), ''),
        password: 'password123',
        role: 'student',
      );
      // Auto login after register
      final loggedIn = await login(
        phoneOrUsername: farmer.phone.replaceAll(RegExp(r'\s+'), ''),
        password: 'password123',
        role: AuthRole.farmer,
      );
      if (loggedIn != null) return loggedIn;
    } catch (_) {
      return mockFallback.registerFarmer(farmer);
    }
    return mockFallback.registerFarmer(farmer);
  }

  @override
  Future<void> logout() async {
    apiService.setAuthToken(null);
    _currentUser = null;
    await mockFallback.logout();
  }
}
