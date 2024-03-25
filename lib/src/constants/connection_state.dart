enum DeviceConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting;

  @override
  toString() {
    return name;
  }
}
