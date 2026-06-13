import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    applyTransparentChrome()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  override func orderFront(_ sender: Any?) {
    applyTransparentChrome()
    super.orderFront(sender)
  }

  private func applyTransparentChrome() {
    isOpaque = false
    backgroundColor = NSColor.clear
    titlebarAppearsTransparent = true
  }
}
