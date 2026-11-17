import 'package:material_ui/material_ui.dart';

class DayflowTextField extends StatelessWidget {
  const DayflowTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.autofocus = false,
    this.maxLines = 1,
    this.onChanged,
    this.textInputAction,
  });
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    validator: validator,
    autofocus: autofocus,
    maxLines: maxLines,
    onChanged: onChanged,
    textInputAction: textInputAction,
    decoration: InputDecoration(labelText: label, hintText: hint),
  );
}
