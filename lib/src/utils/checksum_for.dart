///
///
int checksumFor(List<int> values) {
  int checksum = 0;
  for (int i = 0; i < values.length; i++) {
    checksum += values[i];
  }

  checksum &= 0x7F;
  return checksum;
}
