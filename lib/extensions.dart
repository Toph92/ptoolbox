extension Epkg1 on String {
  /// convert string to SQL string with special character like '
  String? toSql() {
    return "'${replaceAll("'", "''").replaceAll("\\", "\\\\")}'";
  }

  double? toDouble() {
    String sTmp = trim();
    sTmp = sTmp.replaceAll(",", ".");
    return double.parse(sTmp);
  }

  int? toInt() {
    String sTmp = trim();
    return int.parse(sTmp);
  }

  /// return right string
  String right(int len) {
    if (len >= length) {
      return this;
    } else {
      return substring(length - len);
    }
  }

  String left(int len) {
    if (len >= length) {
      return this;
    } else {
      return substring(0, len);
    }
  }

  ///conditionnal concat if this is not empty
  String concat(String append) {
    if (this != "") return this + append;
    return this;
  }

  String capitalizeFirstLetter() {
    if (trim().isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String capitalizeWords() {
    String sResult = "";
    bool bNextIsUpper = true;
    for (final rune in runes) {
      var s = String.fromCharCode(rune);
      if (bNextIsUpper) {
        sResult += s.toUpperCase();
        bNextIsUpper = false;
      } else {
        sResult += s.toLowerCase();
      }
      if (s == ' ' || s == '-') bNextIsUpper = true;
    }
    return sResult;

    // presque mais ce n'est pas bon
    /*return split(RegExp(r'[.-\s]'))
        .map((word) => word.capitalizeFirstLetter())
        .join(' ');*/
  }
}
