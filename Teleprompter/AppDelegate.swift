import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var teleprompterWindow: NSWindow?
    var teleprompterViewModel = TeleprompterViewModel()

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupTeleprompterWindow()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "text.alignleft", accessibilityDescription: "Teleprompter")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 550)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: SettingsView(
                viewModel: teleprompterViewModel,
                showWindow: { [weak self] in
                    self?.showTeleprompter()
                },
                quitApp: {
                    NSApplication.shared.terminate(nil)
                }
            )
        )
    }

    private func setupTeleprompterWindow() {
        let screenHeight = NSScreen.main?.frame.height ?? 0
        let screenWidth = NSScreen.main?.frame.width ?? 0
        let notchHeight: CGFloat = 60
        let overlayHeight: CGFloat = 120

        let contentView = TeleprompterOverlayView(viewModel: teleprompterViewModel)

        teleprompterWindow = NSWindow(
            contentRect: NSRect(
                x: 0,
                y: screenHeight - notchHeight - overlayHeight,
                width: screenWidth,
                height: overlayHeight
            ),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        teleprompterWindow?.isOpaque = false
        teleprompterWindow?.backgroundColor = .clear
        teleprompterWindow?.level = .floating
        teleprompterWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        teleprompterWindow?.contentView = NSHostingView(rootView: contentView)
        teleprompterWindow?.ignoresMouseEvents = true
        teleprompterWindow?.isMovableByWindowBackground = false
        teleprompterWindow?.hasShadow = false

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    @objc func screenDidChange() {
        repositionWindow()
    }

    func repositionWindow() {
        guard let screen = NSScreen.main else { return }
        let screenHeight = screen.frame.height
        let notchHeight: CGFloat = 60
        let overlayHeight: CGFloat = 120

        teleprompterWindow?.setFrame(
            NSRect(
                x: 0,
                y: screenHeight - notchHeight - overlayHeight,
                width: screen.frame.width,
                height: overlayHeight
            ),
            display: true
        )
    }

    @objc func togglePopover() {
        guard let popover = popover else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem?.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    func showTeleprompter() {
        popover?.performClose(nil)
        teleprompterWindow?.orderFront(nil)
        repositionWindow()
    }

    func hideTeleprompter() {
        teleprompterWindow?.orderOut(nil)
    }
}
