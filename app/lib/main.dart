import 'package:flutter/widgets.dart';

void main() {
  runApp(const TidelineBootstrap());
}

/// Temporary bootstrap; replaced by the real app shell in the foundation phase.
class TidelineBootstrap extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
