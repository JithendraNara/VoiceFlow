import AppKit
import SwiftUI
import Carbon.HIToolbox

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var overlayWindow: NSPanel?
    private var viewModel: TeleprompterViewModel?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupOverlayPanel()
        setupGlobalShortcuts()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "waveform", accessibilityDescription: "VoiceFlow")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        viewModel = TeleprompterViewModel()
        popover?.contentViewController = NSHostingController(rootView: SettingsView(viewModel: viewModel!))
        popover?.behavior = .transient
    }

    private func setupOverlayPanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let hostingView = NSHostingView(rootView: TeleprompterOverlayView(viewModel: viewModel!))
        panel.contentView = hostingView

        overlayWindow = panel
    }

    private func setupGlobalShortcuts() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyEvent(event) == true {
                return nil
            }
            return event
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    @discardableResult
    private func handleKeyEvent(_ event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        // Check for Option key
        guard modifiers.contains(.option) else { return false }

        switch event.charactersIgnoringModifiers {
        case "p":
            viewModel?.toggleScrolling()
            return true
        case "r":
            viewModel?.resetScroll()
            return true
        case "j":
            viewModel?.jumpBack()
            return true
        case "h":
            if viewModel?.isOverlayVisible == true {
                hideOverlay()
            } else {
                showOverlay()
            }
            return true
        case "m":
            viewModel?.isMirrorMode.toggle()
            return true
        case "a":
            viewModel?.acceptAISuggestion()
            return true
        case "d":
            viewModel?.dismissAISuggestion()
            return true
        default:
            return false
        }
    }

    func showOverlay() {
        guard let window = overlayWindow else { return }

        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            window.setFrame(NSRect(x: screenFrame.midX - 400,
                                   y: screenFrame.maxY - 500,
                                   width: 800, height: 600), display: true)
        }

        window.orderFront(nil)
        viewModel?.isOverlayVisible = true
    }

    func hideOverlay() {
        overlayWindow?.orderOut(nil)
        viewModel?.isOverlayVisible = false
    }
}
