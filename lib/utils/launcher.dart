import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// All the "open something outside the app" code lives here, so screens stay simple.
class Launcher {
  static Uri youtubeSearch(String query) => Uri.https(
        'www.youtube.com',
        '/results',
        {'search_query': query},
      );

  static Uri shoppingSearch(String query) => Uri.https(
        'www.google.com',
        '/search',
        {'tbm': 'shop', 'q': query},
      );

  /// Specialists near a pincode, shown on Google Maps.
  static Uri specialistsNear(String specialist, String pincode) => Uri.https(
        'www.google.com',
        '/maps/search/',
        {'api': '1', 'query': '$specialist near $pincode India'},
      );

  static Uri call(String number) => Uri(scheme: 'tel', path: number);

  /// Indian pincodes have 6 digits and never start with 0.
  static bool isValidPincode(String text) =>
      RegExp(r'^[1-9][0-9]{5}$').hasMatch(text.trim());

  static Future<void> open(
    BuildContext context,
    Uri uri, {
    String? fallbackMessage,
  }) async {
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fallbackMessage ?? 'Could not open this on your device.'),
        ),
      );
    }
  }
}