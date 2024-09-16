extension NullableDateTimeComparison on DateTime? {
  int compareNullableTo(DateTime? other) {
    if (this == null && other == null) {
      return 0; // Beide sind null
    } else if (this == null) {
      return 1; // this ist null, also größer
    } else if (other == null) {
      return -1; // other ist null, also this ist kleiner
    } else {
      return this!.compareTo(other); // Beide sind nicht null, also normal vergleichen
    }
  }
}

extension EnumComparison on Enum {
  int compareToEnum(Enum other) {
    return index.compareTo(other.index);
  }
}
