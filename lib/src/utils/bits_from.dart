List<int> bitsFrom(int value, [int byte = 1]) {
  List<int> bits = [];

  for (int i = 0; i < (8 * byte); i++) {
    int bit = (value >> i) & 1;
    bits.insert(0, bit);
  }

  return bits;
}
