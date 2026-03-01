import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';

class SessionManager {
  static const String _cookieName = 'sessionToken';
  // 2 days in seconds
  static const int _persistentMaxAge = 2 * 24 * 60 * 60; 

  String generateSessionToken() {
    return const Uuid().v4();
  }

  /// Sets a session cookie.
  /// [persistent]: If true, sets max-age for 2 days. If false, it's a session cookie.
  void setSessionCookie(String token, {bool persistent = false}) {
    String cookieValue = '$_cookieName=$token; path=/; SameSite=Strict; Secure';
    
    if (persistent) {
      cookieValue += '; max-age=$_persistentMaxAge';
    }
    
    html.document.cookie = cookieValue;
  }

  /// Retrieves the session token from the browser cookies.
  String? getSessionToken() {
    final cookies = html.document.cookie;
    if (cookies == null || cookies.isEmpty) return null;

    final cookieList = cookies.split(';');
    for (var cookie in cookieList) {
      final parts = cookie.trim().split('=');
      if (parts.isNotEmpty && parts[0] == _cookieName) {
        return parts.length > 1 ? parts[1] : null;
      }
    }
    return null;
  }

  void clearSession() {
    html.document.cookie = '$_cookieName=; max-age=0; path=/; SameSite=Strict; Secure';
  }
}
