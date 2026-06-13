class AppConfig {
  static const appName = 'CUA Companion';
  static const defaultAgentHost = 'https://stateful-browser-agent.workers.dev';
  static const agentClassName = 'agent-session';
  static const rpcTimeout = Duration(seconds: 60);
  static const reconnectBaseDelay = Duration(seconds: 1);
  static const reconnectMaxDelay = Duration(seconds: 30);
  static const overlayDefaultWidth = 960.0;
  static const overlayDefaultHeight = 640.0;
  static const screenshotMaxEdge = 1920;
  static const maxFileReadBytes = 5 * 1024 * 1024;
}
