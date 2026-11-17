import 'package:material_ui/material_ui.dart';

import '../../app/theme/design_tokens.dart';
import 'dayflow_logo.dart';

/// Uses the approved raster artwork. [mark] allows a future vector asset.
class DayflowBrand extends StatelessWidget {
  const DayflowBrand({super.key, this.mark = const DayflowLogo(size: 32)});
  final Widget? mark;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'DAYFLOW',
    excludeSemantics: true,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mark != null) ...[
          SizedBox(width: 32, height: 32, child: mark),
          const SizedBox(width: DayflowSpace.sm),
        ],
        Flexible(
          child: Text(
            'DAYFLOW',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    ),
  );
}
