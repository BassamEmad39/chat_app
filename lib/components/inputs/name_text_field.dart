import 'package:flutter/material.dart';

class NameTextField extends StatefulWidget {
  const NameTextField({
    super.key,
    this.hintText,
    this.controller,
    this.suffixIcon,
    this.keyboardType,
    this.isPassword = false, 
    this.onChanged,
  });
  final String? hintText;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool isPassword;
  final Function(String)? onChanged;

  @override
  State<NameTextField> createState() => _NameTextFieldState();
}

class _NameTextFieldState extends State<NameTextField> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onChanged,
      obscureText: widget.isPassword ? obscureText : false,

      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      controller: widget.controller,
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
