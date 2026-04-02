import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:memox/core/backup/google_auth_client.dart';

class GoogleSignInService {
  GoogleSignInService() : _googleSignIn = GoogleSignIn(scopes: _scopes);

  static const List<String> _scopes = <String>[
    'https://www.googleapis.com/auth/drive.appdata',
  ];

  final GoogleSignIn _googleSignIn;

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  Future<GoogleSignInAccount?> signInSilently() {
    return _googleSignIn.signInSilently();
  }

  Future<GoogleSignInAccount?> signIn() {
    return _googleSignIn.signIn();
  }

  Future<void> signOut() {
    return _googleSignIn.signOut();
  }

  Future<http.BaseClient?> getAuthClient() async {
    final user = _googleSignIn.currentUser ?? await signInSilently();
    if (user == null) {
      return null;
    }
    final headers = await user.authHeaders;
    return GoogleAuthClient(headers);
  }
}
