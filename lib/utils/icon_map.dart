import 'package:flutter/material.dart';

/// A map from icon code points to const IconData instances.
/// This allows Flutter to tree-shake unused icon fonts in release builds.
/// All icons used for categories must be listed here.
/// All icons used for categories must be listed here so Flutter
/// can tree-shake unused icon fonts in release builds.
const List<IconData> _kIcons = [
  Icons.category_rounded,
  Icons.work_rounded,
  Icons.person_rounded,
  Icons.home_rounded,
  Icons.shopping_cart_rounded,
  Icons.favorite_rounded,
  Icons.school_rounded,
  Icons.fitness_center_rounded,
  Icons.restaurant_rounded,
  Icons.local_cafe_rounded,
  Icons.sports_soccer_rounded,
  Icons.movie_rounded,
  Icons.music_note_rounded,
  Icons.flight_rounded,
  Icons.beach_access_rounded,
  Icons.pets_rounded,
  Icons.account_balance_wallet_rounded,
  Icons.more_horiz_rounded,
  Icons.category,
];

/// Map from icon code point to IconData, built at runtime.
final Map<int, IconData> iconCodePointMap = {
  for (final icon in _kIcons) icon.codePoint: icon,
};

/// Resolves an icon code point to a const IconData from the known set.
/// Falls back to [Icons.category_rounded] if the code point is not found.
IconData resolveIcon(int codePoint) {
  return iconCodePointMap[codePoint] ?? Icons.category_rounded;
}
