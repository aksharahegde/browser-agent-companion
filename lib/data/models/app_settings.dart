class AppSettings {
  const AppSettings({
    required this.agentHost,
    required this.activeSessionId,
    this.authToken = '',
    this.overlayOpacity = 0.95,
    this.overlayFontSize = 13.0,
    this.launchAtLogin = false,
    this.defaultAttachScreenshot = false,
    this.defaultAttachClipboard = false,
    this.overlayX,
    this.overlayY,
    this.overlayWidth,
    this.overlayHeight,
  });

  final String agentHost;
  final String activeSessionId;
  final String authToken;
  final double overlayOpacity;
  final double overlayFontSize;
  final bool launchAtLogin;
  final bool defaultAttachScreenshot;
  final bool defaultAttachClipboard;
  final double? overlayX;
  final double? overlayY;
  final double? overlayWidth;
  final double? overlayHeight;

  AppSettings copyWith({
    String? agentHost,
    String? activeSessionId,
    String? authToken,
    double? overlayOpacity,
    double? overlayFontSize,
    bool? launchAtLogin,
    bool? defaultAttachScreenshot,
    bool? defaultAttachClipboard,
    double? overlayX,
    double? overlayY,
    double? overlayWidth,
    double? overlayHeight,
  }) {
    return AppSettings(
      agentHost: agentHost ?? this.agentHost,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      authToken: authToken ?? this.authToken,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      overlayFontSize: overlayFontSize ?? this.overlayFontSize,
      launchAtLogin: launchAtLogin ?? this.launchAtLogin,
      defaultAttachScreenshot:
          defaultAttachScreenshot ?? this.defaultAttachScreenshot,
      defaultAttachClipboard:
          defaultAttachClipboard ?? this.defaultAttachClipboard,
      overlayX: overlayX ?? this.overlayX,
      overlayY: overlayY ?? this.overlayY,
      overlayWidth: overlayWidth ?? this.overlayWidth,
      overlayHeight: overlayHeight ?? this.overlayHeight,
    );
  }

  static const defaults = AppSettings(
    agentHost: 'https://stateful-browser-agent.workers.dev',
    activeSessionId: '',
    authToken: '',
  );
}
