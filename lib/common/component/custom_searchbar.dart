import 'package:flutter/material.dart';
import 'package:mspeed/common/helper/constant.dart';
import 'custom_textfield.dart';

class CustomSearchBar {
  static Widget searchBarProduct(
      {required TextEditingController controller,
      VoidCallback? onTap,
      String? hint}) {
    return CustomTextField.normalTextField(
      controller: controller,
      hintText: hint ?? "Search Products...",
      prefixIcon: const Icon(Icons.search_rounded),
      padding: EdgeInsets.zero,
      readOnly: true,
      onTap: onTap,
    );
  }

  static Widget buyerSearchBar({
    required TextEditingController controller,
    VoidCallback? onTap,
    String? hint,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Constant.dsSurface,
        borderRadius: BorderRadius.circular(Constant.radiusMd),
        border: Border.all(color: Constant.dsBorder, width: 1),
        // Search bar flat, shadow tipis
        boxShadow: [Constant.shadowSmall],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        decoration: InputDecoration(
          hintText: hint ?? 'Cari produk...',
          hintStyle: TextStyle(
            color: Constant.dsTextSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: Constant.dsTextSecondary, size: 24),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Constant.radiusMd),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Constant.dsSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: Constant.space16, vertical: Constant.space12),
        ),
      ),
    );
  }
}

