import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'constant.dart';

class CustomDropdownSearch {
  Widget dropdownSearch({
    String? label,
    required String hint,
    required List<String> list,
    bool required = false,
    String? selectedItem,
    InputDecoration? inputDecoration,
    Widget? icon,
    Color? borderColor,
    Color? hintColor,
    required Function(String?)? onChanged,
  }) {
    return Theme(
      data: ThemeData(scaffoldBackgroundColor: Colors.white),
      child: DropdownSearch<String>(
        popupProps: PopupProps.dialog(
          showSearchBox: true,
          showSelectedItems: true,
          dialogProps: DialogProps(backgroundColor: Colors.white),
        ),
        items: list,
        selectedItem: selectedItem,
        dropdownButtonProps: DropdownButtonProps(
          icon: icon ??
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xffB9B9B9),
              ),
        ),
        validator: (value) {
          if (required && value?.isNotEmpty != true) {
            return 'Harap isi $label';
          }
          return null;
        },
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: inputDecoration ??
              InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: TextStyle(
                    color: hintColor ?? Colors.black26 /*, fontSize: 12*/),
                filled: true,
                fillColor: Colors.white,
                suffixIconColor: Constant.primaryColor,
                hoverColor: Constant.primaryColor,
                focusColor: Constant.primaryColor,
                prefix: SizedBox(width: 12),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: borderColor ?? Color(0xffB9B9B9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: borderColor ?? Color(0xffB9B9B9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: borderColor ?? Color(0xffB9B9B9)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
        ),
        onChanged: onChanged,
        clearButtonProps: ClearButtonProps(
          icon: Icon(Icons.clear, size: 17, color: Colors.black),
        ),
      ),
    );
  }

  Widget dropdownSearchMapType(
      {String? label,
      required String hint,
      required List<Map<String, String>> list,
      bool required = false,
      Map<String, String>? selectedItem,
      InputDecoration? inputDecoration,
      Widget? icon,
      required Function(Map<String, String>?)? onChanged}) {
    return Theme(
      data: ThemeData(scaffoldBackgroundColor: Colors.white),
      child: DropdownSearch<Map<String, String>>(
        popupProps: PopupProps.dialog(
          showSearchBox: true,
          showSelectedItems: true,
          dialogProps: DialogProps(backgroundColor: Colors.white),
        ),
        items: list,
        selectedItem: selectedItem,
        dropdownButtonProps: DropdownButtonProps(
          icon: icon ??
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xffB9B9B9),
              ),
        ),
        validator: (value) {
          if (required && value?.isNotEmpty != true) {
            return 'Harap isi $label';
          }
          return null;
        },
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: inputDecoration ??
              InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: hint,
                hintStyle: TextStyle(color: Colors.black26 /*, fontSize: 12*/),
                filled: true,
                fillColor: Colors.white,
                suffixIconColor: Constant.primaryColor,
                hoverColor: Constant.primaryColor,
                focusColor: Constant.primaryColor,
                prefix: SizedBox(width: 12),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffB9B9B9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffB9B9B9)),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xffB9B9B9)),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
        ),
        onChanged: onChanged,
        clearButtonProps: ClearButtonProps(
          icon: Icon(Icons.clear, size: 17, color: Colors.black),
        ),
      ),
    );
  }

  Widget dropdownWoSearch(
      {String? label,
      required String hint,
      String? selectedItem,
      required List<String> list,
      bool required = false,
      InputDecoration? inputDecoration,
      Widget? icon,
      required Function(String?)? onChanged}) {
    return DropdownSearch<String>(
      popupProps:
          PopupProps.menu(showSearchBox: false, showSelectedItems: true),
      items: list,
      selectedItem: selectedItem,
      dropdownButtonProps: DropdownButtonProps(
        icon: icon ??
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 0, 24),
              child: const Icon(Icons.arrow_drop_down, color: Colors.black87),
            ),
      ),
      validator: (value) {
        if (required && value?.isNotEmpty != true) {
          return 'Harap isi $label';
        }
        return null;
      },
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: inputDecoration ??
            InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.black26),
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: .5)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: .5)),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Constant.primaryColor, width: .5))),
      ),
      onChanged: onChanged,
      clearButtonProps: ClearButtonProps(
        icon: Icon(Icons.clear, size: 17, color: Colors.black),
      ),
    );
  }

  Widget dropdown2(
      {String? label,
      required String hint,
      required List<DropdownMenuItem<String>> list,
      bool required = true,
      bool readOnly = false,
      bool enabled = true,
      Color? fillColor,
      String? selectedItem,
      required Function(String?)? onChanged}) {
    return DropdownButtonFormField(
      items: readOnly ? null : list,
      onChanged: readOnly ? null : onChanged,
      onSaved: (val) => FocusManager.instance.primaryFocus?.unfocus(),
      icon: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 12, 64),
        child: Icon(Icons.keyboard_arrow_down,
            color: Constant.textHintColor2, size: 24),
      ),
      // style: Constant.primaryTextStyle,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        hintText: hint,
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
            width: 0.5,
            color: Constant.borderSearchColor,
            style: BorderStyle.solid,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 0.5,
            color: Constant.borderSearchColor,
            style: BorderStyle.solid,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            width: 1,
            color: Constant.primaryColor,
            style: BorderStyle.solid,
          ),
        ),
      ),
      hint: Text(hint),
      value: selectedItem,
      // validator: (value) {
      //   if (required && value?.isNotEmpty != true) {
      //     return 'Harap isi $label';
      //   }
      // },
    );
  }

  Widget dropdownFilter(
      {String? label,
      required String hint,
      required List<DropdownMenuItem<String>> list,
      bool required = false,
      String? selectedItem,
      required Function(String?)? onChanged}) {
    return DropdownButtonFormField(
      padding: EdgeInsets.only(top: 8),
      items: list,
      onChanged: onChanged,
      elevation: 0,
      icon: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 12, 64),
        child: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.black,
        ),
      ),
      // style: Constant.primaryTextStyle,
      isExpanded: true,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black26, fontSize: 12),
        filled: true,
        fillColor: Colors.white,
        suffixIconColor: Constant.primaryColor,
        hoverColor: Constant.primaryColor,
        focusColor: Constant.primaryColor,
        prefix: SizedBox(width: 12),
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1),
          borderRadius: BorderRadius.circular(14),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      hint: Text(hint),
      value: selectedItem,
      validator: (value) {
        if (required && value?.isNotEmpty != true) {
          return 'Harap isi $label';
        }
        return null;
      },
    );
  }
}
