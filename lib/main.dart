import 'package:flutter/material.dart';

import 'app.dart';
import 'services/mock_auth_service.dart';

void main() {
  // Replace MockAuthService with a real AuthService to use a live API.
  runApp(App(authService: MockAuthService()));
}
