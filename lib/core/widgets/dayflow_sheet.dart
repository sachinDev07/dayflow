import 'package:material_ui/material_ui.dart';

import '../../app/theme/design_tokens.dart';

/// Shared keyboard-safe sheet container; callers own feature form state.
Future<T?> showDayflowSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) => showModalBottomSheet<T>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
      ? AnimationStyle.noAnimation
      : const AnimationStyle(
          duration: DayflowMotion.interaction,
          reverseDuration: DayflowMotion.interaction,
        ),
  builder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        DayflowSpace.page,
        0,
        DayflowSpace.page,
        DayflowSpace.xl,
      ),
      child: builder(context),
    ),
  ),
);
