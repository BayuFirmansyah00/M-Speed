import 'package:flutter/material.dart';

import '../helper/constant.dart';
import '../helper/dropdown_search.dart';

class CustomDropdown {
  static Widget normalDropdown({
    String? labelText,
    String? hintText,
    int line = 1,
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    bool required = true,
    bool enabled = true,
    Color? fillColor,
    Color? borderColor,
    Color? activeBorderColor,
    Color? iconColor,
    double? borderWidth,
    double? activeBorderWidth,
    String? selectedItem,
    Function(String?)? onChanged,
    required List<DropdownMenuItem<String>> list,
    TextEditingController? controller,
    TextAlign? inputAlign,
    CrossAxisAlignment align = CrossAxisAlignment.start,
    EdgeInsetsGeometry? padding,
    double? labelFontSize,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (labelText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(
                    labelText,
                    style: Constant.primaryTextStyle.copyWith(
                      fontSize: labelFontSize ?? 14,
                      fontWeight: Constant.medium,
                    ),
                  ),
                  required
                      ? Text(
                          '*',
                          style: Constant.primaryTextStyle.copyWith(
                            fontSize: labelFontSize ?? 14,
                            fontWeight: Constant.medium,
                            color: Colors.red,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          DropdownButtonFormField(
            items: readOnly ? null : list,
            onChanged: readOnly ? null : onChanged,
            onSaved: (val) => FocusManager.instance.primaryFocus?.unfocus(),
            icon: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 12, 64),
              child: Icon(Icons.keyboard_arrow_down,
                  color: iconColor ?? Constant.textHintColor2, size: 24),
            ),
            // style: Constant.primaryTextStyle,
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              hintText: hintText,
              hintStyle: TextStyle(color: Constant.textHintColor2),
              filled: true,
              enabled: enabled ?? true,
              fillColor: fillColor ??
                  ((enabled ?? false) ? Colors.white : Constant.textHintColor),
              suffixIconColor: Constant.primaryColor,
              hoverColor: Constant.primaryColor,
              focusColor: Constant.primaryColor,
              prefix: SizedBox(width: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  width: borderWidth ?? 0.5,
                  color: borderColor ?? Constant.borderSearchColor,
                  style: BorderStyle.solid,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  width: borderWidth ?? 0.5,
                  color: borderColor ?? Constant.borderSearchColor,
                  style: BorderStyle.solid,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  width: activeBorderWidth ?? 1,
                  color: activeBorderColor ?? Constant.borderSearchColor,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            hint: Text(hintText ?? ''),
            value: selectedItem,
            // validator: (value) {
            //   if (required && value?.isNotEmpty != true) {
            //     return 'Harap isi $label';
            //   }
            // },
          ),
        ],
      ),
    );
  }

  static Widget filterDropdown({
    String? labelText,
    String? hintText,
    int line = 1,
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    bool required = false,
    String? selectedItem,
    Function(String?)? onChanged,
    required List<DropdownMenuItem<String>> list,
    TextEditingController? controller,
    TextAlign? inputAlign,
    CrossAxisAlignment align = CrossAxisAlignment.start,
    EdgeInsetsGeometry? padding,
    double? labelFontSize,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (labelText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                labelText,
                style: Constant.primaryTextStyle.copyWith(
                  fontSize: labelFontSize ?? 14,
                  fontWeight: Constant.medium,
                ),
              ),
            ),
          CustomDropdownSearch().dropdownFilter(
            label: labelText,
            hint: hintText ?? "",
            list: list,
            onChanged: onChanged,
            required: required,
            selectedItem: selectedItem,
          ),
        ],
      ),
    );
  }

  static Widget searchDropdown({
    String? labelText,
    String? hintText,
    int line = 1,
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    bool required = false,
    String? selectedItem,
    Function(String?)? onChanged,
    required List<String> list,
    TextEditingController? controller,
    TextAlign? inputAlign,
    CrossAxisAlignment align = CrossAxisAlignment.start,
    EdgeInsetsGeometry? padding,
    double? labelFontSize,
    Color? borderColor,
    Color? hintColor,
    EdgeInsetsGeometry? labelPadding,
    TextStyle? labelTextStyle,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        if (labelText != null)
          Padding(
            padding: labelPadding ?? EdgeInsets.zero,
            child: Row(
              children: [
                Text(
                  labelText,
                  style: labelTextStyle ??
                      TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                required
                    ? Text(
                        '*',
                        style: Constant.primaryTextStyle.copyWith(
                          fontSize: labelFontSize ?? 14,
                          fontWeight: Constant.medium,
                          color: Colors.red,
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        CustomDropdownSearch().dropdownSearch(
          label: labelText,
          hint: hintText ?? "",
          list: list,
          onChanged: onChanged,
          required: required,
          selectedItem: selectedItem,
          borderColor: borderColor,
          hintColor: hintColor,
        ),
      ],
    );
  }

  static Widget searchDropdownMapType({
    String? labelText,
    String? hintText,
    int line = 1,
    TextInputType type = TextInputType.text,
    bool readOnly = false,
    bool required = false,
    Map<String, String>? selectedItem,
    Function(Map<String, String>?)? onChanged,
    required List<Map<String, String>> list,
    TextEditingController? controller,
    TextAlign? inputAlign,
    CrossAxisAlignment align = CrossAxisAlignment.start,
    EdgeInsetsGeometry? padding,
    double? labelFontSize,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        if (labelText != null)
          Text(
            labelText,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        CustomDropdownSearch().dropdownSearchMapType(
          label: labelText,
          hint: hintText ?? "",
          selectedItem: selectedItem,
          list: list,
          onChanged: onChanged,
          required: required,
        ),
      ],
    );
  }
}
