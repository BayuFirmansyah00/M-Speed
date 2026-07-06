
import 'package:intl/intl.dart';

num usdRate = 1;

convertToUsd(num amount){
  return amount / usdRate;
}

convertToIdr(num amount){
  return amount * usdRate;
}

enum Currency {
  USD, IDR
}

extension NumCurrencyExt on num {

  num get idrToUsd {
    return this / usdRate;
  }

  num get usdToIdr {
    return this * usdRate;
  }
}

extension CurrencyExt on Currency {
  int get id {
    switch(this){
      case Currency.USD: return 1;
      default: return 0;
    }
  }

  String get locale {
    switch(this){
      case Currency.USD : return 'en_US';
      default : return 'in_ID';
    }
  }

  String currencyStr({bool useSymbol = false}){
    switch(this){
      case Currency.IDR:
        return "Rp";
      case Currency.USD:
        return useSymbol ? "\$" : "US\$";
    }
  }

  List<num> templateDPHaji(num price){
    return [
      (price * 1),
      (price * 0.75),
      (price * 0.5),
      (price * 0.25)
    ];
  }

  NumberFormat formatter({bool usePrefix = false}){
    final String prefix = usePrefix ? currencyStr() : "";
    switch(this){
      case Currency.USD:
        return NumberFormat("$prefix #,###.##", locale);
      case Currency.IDR:
        return NumberFormat("$prefix #,###.##", locale);
    }
  }

}