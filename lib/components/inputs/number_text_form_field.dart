import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberTextFormField extends StatelessWidget {
  const NumberTextFormField({
    super.key,
    this.validator,
    this.hintText,
    this.controller,
    this.suffixIcon,
    this.keyboardType,
  });
  final String? Function(String?)? validator;
  final String? hintText;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      validator: validator,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: suffixIcon,
        suffixIconConstraints: BoxConstraints(maxWidth: 50),
      ),
    );
  }
}
