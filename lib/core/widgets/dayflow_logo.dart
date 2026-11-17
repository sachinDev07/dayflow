import 'package:material_ui/material_ui.dart';

/// Displays the exact supplied PNG through a central square viewport.
/// Source art is 1536x1024; the icon occupies its central ~728px square.
/// This changes display framing only; the bundled image is byte-for-byte original.
class DayflowLogo extends StatelessWidget {
  const DayflowLogo({super.key, this.size = 36});
  final double size;

  static const asset = 'assets/images/dayflow_app_icon.png';

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: SizedBox.square(
        dimension: size,
        child: OverflowBox(
          maxWidth: size * 1536 / 728,
          maxHeight: size * 1024 / 728,
          child: Image.asset(
            asset,
            width: size * 1536 / 728,
            height: size * 1024 / 728,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ),
      ),
    ),
  );
}
