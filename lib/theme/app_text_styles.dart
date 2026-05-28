import 'package:flutter/material.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle title(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
      fontWeight: FontWeight.w800,
    );
  }

  static TextStyle subtitle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle body(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
