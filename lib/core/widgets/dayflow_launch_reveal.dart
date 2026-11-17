import 'package:material_ui/material_ui.dart';

import '../../app/theme/design_tokens.dart';

/// Reveals the ready UI without an extra splash route, timer, or input barrier.
class DayflowLaunchReveal extends StatefulWidget {
  const DayflowLaunchReveal({super.key, required this.child});
  final Widget child;

  @override
  State<DayflowLaunchReveal> createState() => _DayflowLaunchRevealState();
}

class _DayflowLaunchRevealState extends State<DayflowLaunchReveal>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: DayflowMotion.entrance,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _controller,
    alwaysIncludeSemantics: true,
    child: widget.child,
  );
}
