import 'package:flutter/material.dart';

class NameTextFormField extends StatefulWidget {
  const NameTextFormField({
    super.key,
    this.hintText,
    this.controller,
    this.suffixIcon,
    this.keyboardType,
    this.isPassword = false, 
    this.onChanged,
    this.validator,
  });
  final String? hintText;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool isPassword;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  @override
  State<NameTextFormField> createState() => _NameTextFieldState();
}

class _NameTextFieldState extends State<NameTextFormField> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: widget.onChanged,
      obscureText: widget.isPassword ? obscureText : false,

      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() {
                  obscureText = !obscureText;
                }),
              )
            : null,
        suffixIconConstraints: BoxConstraints(maxWidth: 45),
      ),
    );
  }
}
