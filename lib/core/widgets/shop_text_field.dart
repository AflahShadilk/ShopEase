import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shared input. Password visibility is local reactive GetX state.
class ShopTextField extends StatelessWidget {
  const ShopTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.validator,
    this.keyboardType,
    this.isPassword = false,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool isPassword;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    if (!isPassword) return _field(null);

    // ObxValue owns a small RxBool for each password field instance.
    return ObxValue<RxBool>((visibility) => _field(visibility), false.obs);
  }

  Widget _field(RxBool? visibility) {
    final showPassword = visibility?.value ?? false;
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: isPassword && !showPassword,
      autocorrect: !isPassword,
      enableSuggestions: !isPassword,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: isPassword
            ? IconButton(
                tooltip: showPassword ? 'Hide password' : 'Show password',
                icon: Icon(
                  showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => visibility!.value = !visibility.value,
              )
            : null,
      ),
    );
  }
}
