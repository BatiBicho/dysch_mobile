import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Llaves constantes para evitar errores de dedo
  static const _userIdKey = 'USER_ID';
  static const _tokenKey = 'AUTH_TOKEN';
  static const _userNameKey = 'USER_NAME';

  // --- Manejo del ID de Usuario ---
  Future<void> saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, id);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // --- Manejo del Token (Vital para la API) ---
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // --- Extra: Guardar nombre para mostrarlo en el Perfil rápido ---
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  // --- Limpieza total (Cerrar Sesión) ---
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra todo lo guardado en la app
  }
}
