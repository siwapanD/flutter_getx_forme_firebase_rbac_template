import 'core/app.dart';

/// Application entry point
/// 
/// This is the main entry point for the Flutter application.
/// It calls the bootstrap function which handles all initialization
/// including Firebase setup, error handling, and app startup.
void main() async {
  await bootstrap();
}